//
//  AppViewModel.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation

final class AppViewModel {

    // Called after any state mutation — used to request a TUI re-render.
    var onStateChange: () -> Void = {}

    var currentScreen: AppScreen = .list {
        didSet { onStateChange() }
    }
    var providers: [Provider] = [] {
        didSet { onStateChange() }
    }
    var activeProviderID: UUID? = nil {
        didSet { onStateChange() }
    }
    var statusMessage: String = "" {
        didSet { onStateChange() }
    }
    var duplicateWarning: DuplicateWarning? = nil {
        didSet { onStateChange() }
    }

    private let store = ProviderStore.shared
    private let configManager = ConfigManager.shared

    struct DuplicateWarning {
        enum Kind { case sameURL, differentURL }
        let existingProvider: Provider
        let kind: Kind
        let pendingProvider: Provider
    }

    init() {
        reloadProviders()
    }

    // MARK: - State helpers

    func reloadProviders() {
        store.load()
        providers = store.providers
        activeProviderID = store.activeProviderID
    }

    var isDefaultActive: Bool {
        activeProviderID == nil
    }

    func isActive(_ provider: Provider) -> Bool {
        provider.id == activeProviderID
    }

    // MARK: - Navigation

    func navigate(to screen: AppScreen) {
        duplicateWarning = nil
        currentScreen = screen
    }

    // MARK: - Provider actions

    func activateDefault() {
        store.deactivateAll()
        configManager.clearEnvVariables()
        reloadProviders()
        statusMessage = "Default activated"
    }

    func activateProvider(_ provider: Provider) {
        store.activateProvider(provider)
        configManager.updateEnvVariables(provider.envVariables)
        reloadProviders()
        statusMessage = "Activated: \(provider.name)"
    }

    func submitNewProvider(name: String, envVariables: [String: String], icon: String) {
        let token = envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
        let url = envVariables["ANTHROPIC_BASE_URL"] ?? ""

        switch store.checkTokenDuplicate(token: token, url: url, excludingID: nil) {
        case .unique:
            commitAddProvider(name: name, envVariables: envVariables, icon: icon)
        case .duplicateWithSameURL(let existing):
            duplicateWarning = DuplicateWarning(
                existingProvider: existing,
                kind: .sameURL,
                pendingProvider: Provider(name: name, envVariables: envVariables, icon: icon)
            )
        case .duplicateWithDifferentURL(let existing):
            duplicateWarning = DuplicateWarning(
                existingProvider: existing,
                kind: .differentURL,
                pendingProvider: Provider(name: name, envVariables: envVariables, icon: icon)
            )
        }
    }

    func commitAddProvider(name: String, envVariables: [String: String], icon: String) {
        let provider = Provider(name: name, envVariables: envVariables, icon: icon)
        store.addProvider(provider)
        reloadProviders()
        statusMessage = "Added: \(name)"
        navigate(to: .list)
    }

    func submitEditProvider(id: UUID, name: String, envVariables: [String: String], icon: String, wasActive: Bool) {
        let token = envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
        let url = envVariables["ANTHROPIC_BASE_URL"] ?? ""

        switch store.checkTokenDuplicate(token: token, url: url, excludingID: id) {
        case .unique:
            commitEditProvider(id: id, name: name, envVariables: envVariables, icon: icon, wasActive: wasActive)
        case .duplicateWithSameURL(let existing):
            duplicateWarning = DuplicateWarning(
                existingProvider: existing,
                kind: .sameURL,
                pendingProvider: Provider(id: id, name: name, envVariables: envVariables, icon: icon, isActive: wasActive)
            )
        case .duplicateWithDifferentURL(let existing):
            duplicateWarning = DuplicateWarning(
                existingProvider: existing,
                kind: .differentURL,
                pendingProvider: Provider(id: id, name: name, envVariables: envVariables, icon: icon, isActive: wasActive)
            )
        }
    }

    func commitEditProvider(id: UUID, name: String, envVariables: [String: String], icon: String, wasActive: Bool) {
        let updated = Provider(id: id, name: name, envVariables: envVariables, icon: icon, isActive: wasActive)
        store.updateProvider(updated)
        if wasActive {
            configManager.updateEnvVariables(envVariables)
        }
        reloadProviders()
        statusMessage = "Updated: \(name)"
        navigate(to: .list)
    }

    func deleteProvider(_ provider: Provider) {
        let wasActive = isActive(provider)
        store.deleteProvider(provider)
        if wasActive {
            configManager.clearEnvVariables()
        }
        reloadProviders()
        statusMessage = "Deleted: \(provider.name)"
        navigate(to: .list)
    }

    func dismissDuplicateWarning() {
        duplicateWarning = nil
    }
}
