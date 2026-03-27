//
//  Models.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation

// MARK: - Provider

struct Provider: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var isActive: Bool
    var envVariables: [String: String]

    /// Creates a new provider with a fresh UUID (for adding).
    init(name: String, envVariables: [String: String], icon: String = "ClaudeLogo", isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.envVariables = envVariables
        self.icon = icon
        self.isActive = isActive
    }

    /// Creates a provider with an existing UUID (for editing — preserves identity).
    init(id: UUID, name: String, envVariables: [String: String], icon: String, isActive: Bool) {
        self.id = id
        self.name = name
        self.envVariables = envVariables
        self.icon = icon
        self.isActive = isActive
    }

    // Explicit Codable to ensure id is always encoded/decoded.
    enum CodingKeys: String, CodingKey {
        case id, name, icon, isActive, envVariables
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "OtherLogo"
        isActive = try container.decode(Bool.self, forKey: .isActive)
        envVariables = try container.decodeIfPresent([String: String].self, forKey: .envVariables) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(envVariables, forKey: .envVariables)
    }
}

// MARK: - ProviderTemplate

struct ProviderTemplate: Hashable, Equatable {
    let name: String
    let envVariables: [String: String]
    let icon: String

    static let anthropic = ProviderTemplate(
        name: "Anthropic",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.anthropic.com",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5-20251001",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-5",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-4-5"
        ],
        icon: "ClaudeLogo"
    )

    static let zhipuAI = ProviderTemplate(
        name: "Zhipu AI",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://open.bigmodel.cn/api/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
        ],
        icon: "ZhipuLogo"
    )

    static let zai = ProviderTemplate(
        name: "z.ai",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.6",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.6"
        ],
        icon: "ZaiLogo"
    )

    static let moonshotAI = ProviderTemplate(
        name: "Moonshot AI",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.moonshot.cn/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "kimi-k2-turbo-preview",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "kimi-k2-turbo-preview",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "kimi-k2-turbo-preview"
        ],
        icon: "MoonshotLogo"
    )

    static let minimax = ProviderTemplate(
        name: "MiniMax",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.minimaxi.com/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "MiniMax-M2.7",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "MiniMax-M2.7",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "MiniMax-M2.7",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
            "API_TIMEOUT_MS": "3000000"
        ],
        icon: "OtherLogo"
    )

    static let other = ProviderTemplate(
        name: "Other",
        envVariables: [
            "ANTHROPIC_BASE_URL": "",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": ""
        ],
        icon: "OtherLogo"
    )

    static let allTemplates: [ProviderTemplate] = [
        .anthropic, .zhipuAI, .zai, .moonshotAI, .minimax, .other
    ]
}

// MARK: - TokenCheckResult

enum TokenCheckResult {
    case unique
    case duplicateWithSameURL(Provider)
    case duplicateWithDifferentURL(Provider)
}

// MARK: - AppScreen (navigation state)

enum AppScreen: Equatable {
    case list
    case selectTemplate
    case addForm(ProviderTemplate)
    case edit(Provider)
    case deleteConfirm(Provider)

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list): return true
        case (.selectTemplate, .selectTemplate): return true
        case (.addForm(let a), .addForm(let b)): return a == b
        case (.edit(let a), .edit(let b)): return a == b
        case (.deleteConfirm(let a), .deleteConfirm(let b)): return a == b
        default: return false
        }
    }
}
