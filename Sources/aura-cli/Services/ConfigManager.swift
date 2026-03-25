//
//  ConfigManager.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation

final class ConfigManager {

    static let shared = ConfigManager()

    private var configDirectory: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude")
    }

    private var configURL: URL {
        configDirectory.appendingPathComponent("settings.json")
    }

    private var backupURL: URL {
        configDirectory.appendingPathComponent("settings.json.backup")
    }

    private init() {}

    // MARK: - Ensure config exists

    private func ensureConfigExists() {
        let fm = FileManager.default
        if !fm.fileExists(atPath: configDirectory.path) {
            try? fm.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        if !fm.fileExists(atPath: configURL.path) {
            let emptyConfig: [String: Any] = [:]
            if let data = try? JSONSerialization.data(
                withJSONObject: emptyConfig,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            ) {
                try? data.write(to: configURL)
            }
        }
    }

    // MARK: - Read

    func readEnvVariables() -> [String: String] {
        ensureConfigExists()
        guard let data = try? Data(contentsOf: configURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let env = json["env"] as? [String: Any]
        else {
            return [:]
        }
        // Convert all env values to strings
        var result: [String: String] = [:]
        for (key, value) in env {
            if let str = value as? String {
                result[key] = str
            } else {
                result[key] = "\(value)"
            }
        }
        return result
    }

    // MARK: - Write

    /// Updates only the `env` key in settings.json, preserving all other top-level keys.
    @discardableResult
    func updateEnvVariables(_ envVars: [String: String]) -> Bool {
        ensureConfigExists()
        createBackup()

        var config: [String: Any]
        if let data = try? Data(contentsOf: configURL),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = json
        } else {
            config = [:]
        }

        config["env"] = envVars

        do {
            let data = try JSONSerialization.data(
                withJSONObject: config,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            )
            try data.write(to: configURL)
            return true
        } catch {
            restoreBackup()
            return false
        }
    }

    /// Removes ANTHROPIC_BASE_URL and ANTHROPIC_AUTH_TOKEN from the env key (restores Default).
    @discardableResult
    func clearEnvVariables() -> Bool {
        ensureConfigExists()
        createBackup()

        var config: [String: Any]
        if let data = try? Data(contentsOf: configURL),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            config = json
        } else {
            config = [:]
        }

        var env = (config["env"] as? [String: Any]) ?? [:]
        env.removeValue(forKey: "ANTHROPIC_BASE_URL")
        env.removeValue(forKey: "ANTHROPIC_AUTH_TOKEN")
        env.removeValue(forKey: "ANTHROPIC_DEFAULT_HAIKU_MODEL")
        env.removeValue(forKey: "ANTHROPIC_DEFAULT_SONNET_MODEL")
        env.removeValue(forKey: "ANTHROPIC_DEFAULT_OPUS_MODEL")
        config["env"] = env

        do {
            let data = try JSONSerialization.data(
                withJSONObject: config,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            )
            try data.write(to: configURL)
            return true
        } catch {
            restoreBackup()
            return false
        }
    }

    // MARK: - Backup

    private func createBackup() {
        let fm = FileManager.default
        guard fm.fileExists(atPath: configURL.path) else { return }
        try? fm.removeItem(at: backupURL)
        try? fm.copyItem(at: configURL, to: backupURL)
    }

    private func restoreBackup() {
        let fm = FileManager.default
        guard fm.fileExists(atPath: backupURL.path) else { return }
        try? fm.removeItem(at: configURL)
        try? fm.copyItem(at: backupURL, to: configURL)
        try? fm.removeItem(at: backupURL)
    }
}
