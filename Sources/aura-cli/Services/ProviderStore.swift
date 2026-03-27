//
//  ProviderStore.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation

/// Persistence model for aura-providers.json
private struct ProviderStorageFile: Codable {
    var providers: [Provider]
    var activeProviderID: String?
}

final class ProviderStore {

    static let shared = ProviderStore()

    private var storageURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
            .appendingPathComponent("aura-providers.json")
    }

    private(set) var providers: [Provider] = []
    private(set) var activeProviderID: UUID? = nil

    var activeProvider: Provider? {
        guard let id = activeProviderID else { return nil }
        return providers.first { $0.id == id }
    }

    private init() {
        load()
    }

    // MARK: - Load / Save

    func load() {
        guard let data = try? Data(contentsOf: storageURL),
              let stored = try? JSONDecoder().decode(ProviderStorageFile.self, from: data)
        else {
            providers = []
            activeProviderID = nil
            return
        }
        providers = stored.providers
        if let idStr = stored.activeProviderID {
            activeProviderID = UUID(uuidString: idStr)
        } else {
            activeProviderID = nil
        }
    }

    private func save() {
        // Ensure ~/.claude directory exists
        let dir = storageURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let stored = ProviderStorageFile(
            providers: providers,
            activeProviderID: activeProviderID?.uuidString
        )
        if let data = try? JSONEncoder().encode(stored) {
            try? data.write(to: storageURL)
        }
    }

    // MARK: - CRUD

    func addProvider(_ provider: Provider) {
        var newProvider = provider
        newProvider.isActive = false
        providers.append(newProvider)
        save()
    }

    func updateProvider(_ provider: Provider) {
        if let index = providers.firstIndex(where: { $0.id == provider.id }) {
            providers[index] = provider
            save()
        }
    }

    func deleteProvider(_ provider: Provider) {
        providers.removeAll { $0.id == provider.id }
        if activeProviderID == provider.id {
            activeProviderID = nil
        }
        save()
    }

    // MARK: - Activation

    func activateProvider(_ provider: Provider) {
        for i in providers.indices {
            providers[i].isActive = (providers[i].id == provider.id)
        }
        activeProviderID = provider.id
        save()
    }

    func deactivateAll() {
        for i in providers.indices {
            providers[i].isActive = false
        }
        activeProviderID = nil
        save()
    }

    // MARK: - Token duplicate detection

    func checkTokenDuplicate(token: String, url: String, excludingID: UUID?) -> TokenCheckResult {
        guard !token.isEmpty else { return .unique }
        for provider in providers {
            if let excID = excludingID, provider.id == excID { continue }
            let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            guard providerToken == token else { continue }
            let providerURL = provider.envVariables["ANTHROPIC_BASE_URL"] ?? ""
            if providerURL == url {
                return .duplicateWithSameURL(provider)
            } else {
                return .duplicateWithDifferentURL(provider)
            }
        }
        return .unique
    }

    // MARK: - Icon inference

    static func inferIcon(from baseURL: String) -> String {
        guard !baseURL.isEmpty, let url = URL(string: baseURL), let host = url.host else {
            return "OtherLogo"
        }
        let h = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        if h.contains("anthropic.com") { return "ClaudeLogo" }
        if h.contains("bigmodel.cn") { return "ZhipuLogo" }
        if h.contains("z.ai") { return "ZaiLogo" }
        if h.contains("moonshot.cn") { return "MoonshotLogo" }
        if h.contains("minimaxi.com") { return "OtherLogo" }
        return "OtherLogo"
    }
}
