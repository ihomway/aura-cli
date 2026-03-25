//
//  ConfigImportService.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation

final class ConfigImportService {

    static let shared = ConfigImportService()

    private let configManager = ConfigManager.shared
    private let providerStore = ProviderStore.shared

    private init() {}

    // MARK: - Startup Sync (three-phase validation)

    /// Synchronises provider state against ~/.claude/settings.json on startup.
    func syncOnStartup() {
        let env = configManager.readEnvVariables()
        guard let configToken = env["ANTHROPIC_AUTH_TOKEN"], !configToken.isEmpty else {
            // No token in config — leave state as-is (Default is active)
            return
        }
        let configBaseURL = env["ANTHROPIC_BASE_URL"] ?? ""

        // Phase 1: Check if the saved active provider matches the config token.
        if let activeID = providerStore.activeProviderID,
           let activeProvider = providerStore.providers.first(where: { $0.id == activeID }) {
            let providerToken = activeProvider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            if providerToken == configToken {
                // Already in sync — ensure isActive flag is set
                if !activeProvider.isActive {
                    providerStore.activateProvider(activeProvider)
                }
                return
            }
        }

        // Phase 2: Search all providers for a matching token.
        for provider in providerStore.providers {
            let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            if providerToken == configToken {
                providerStore.activateProvider(provider)
                return
            }
        }

        // Phase 3: No match — create a new provider from the config values.
        // Skip if an identical provider already exists (same URL + token).
        let alreadyExists = providerStore.providers.contains {
            $0.envVariables["ANTHROPIC_AUTH_TOKEN"] == configToken &&
            $0.envVariables["ANTHROPIC_BASE_URL"] == configBaseURL
        }
        guard !alreadyExists else {
            if let existing = providerStore.providers.first(where: {
                $0.envVariables["ANTHROPIC_AUTH_TOKEN"] == configToken
            }) {
                providerStore.activateProvider(existing)
            }
            return
        }

        let (name, icon) = templateInfo(for: configBaseURL)
        var newEnv = env
        newEnv["ANTHROPIC_AUTH_TOKEN"] = configToken
        let newProvider = Provider(name: name, envVariables: newEnv, icon: icon)
        providerStore.addProvider(newProvider)
        // Re-fetch after add to get stable reference
        if let added = providerStore.providers.last {
            providerStore.activateProvider(added)
        }
    }

    // MARK: - Runtime Sync (external config change detection)

    /// Detects external changes to settings.json and reconciles provider state.
    /// Returns true if state changed.
    @discardableResult
    func syncConfigurationState() -> Bool {
        let env = configManager.readEnvVariables()

        guard let configToken = env["ANTHROPIC_AUTH_TOKEN"], !configToken.isEmpty else {
            if providerStore.activeProviderID != nil {
                providerStore.deactivateAll()
                return true
            }
            return false
        }

        // Check if the active provider still matches.
        if let activeID = providerStore.activeProviderID,
           let activeProvider = providerStore.providers.first(where: { $0.id == activeID }) {
            let providerToken = activeProvider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            if providerToken == configToken {
                return false // No change
            }
        }

        // Search all providers for a matching token.
        for provider in providerStore.providers {
            let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            if providerToken == configToken {
                providerStore.activateProvider(provider)
                return true
            }
        }

        // No match — create a new provider from the config.
        let configBaseURL = env["ANTHROPIC_BASE_URL"] ?? ""
        let alreadyExists = providerStore.providers.contains {
            $0.envVariables["ANTHROPIC_AUTH_TOKEN"] == configToken &&
            $0.envVariables["ANTHROPIC_BASE_URL"] == configBaseURL
        }
        if !alreadyExists && !configBaseURL.isEmpty {
            let (name, icon) = templateInfo(for: configBaseURL)
            let newProvider = Provider(name: name, envVariables: env, icon: icon)
            providerStore.addProvider(newProvider)
            if let added = providerStore.providers.last {
                providerStore.activateProvider(added)
            }
            return true
        }

        return false
    }

    // MARK: - Template matching helpers

    private func templateInfo(for baseURL: String) -> (name: String, icon: String) {
        for template in ProviderTemplate.allTemplates {
            let templateURL = template.envVariables["ANTHROPIC_BASE_URL"] ?? ""
            if !templateURL.isEmpty && templateURL == baseURL {
                return (template.name, template.icon)
            }
        }
        // Fallback: infer icon from URL domain
        let icon = ProviderStore.inferIcon(from: baseURL)
        return ("Other", icon)
    }
}
