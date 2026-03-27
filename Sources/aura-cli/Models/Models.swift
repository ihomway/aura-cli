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
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "MiniMax-M2",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "MiniMax-M2",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "MiniMax-M2",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
            "API_TIMEOUT_MS": "3000000"
        ],
        icon: "OtherLogo"
    )

    static let miniMaxIo = ProviderTemplate(
        name: "MiniMax.io",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.minimax.io/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "MiniMax-M2",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "MiniMax-M2",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "MiniMax-M2",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
            "API_TIMEOUT_MS": "3000000"
        ],
        icon: "OtherLogo"
    )

    static let deepSeekAI = ProviderTemplate(
        name: "DeepSeek",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "deepseek-chat",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "deepseek-chat",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-chat",
            "API_TIMEOUT_MS": "600000",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
        ],
        icon: "DeepSeekLogo"
    )

    static let aliyuncsAI = ProviderTemplate(
        name: "Aliyuncs",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://dashscope.aliyuncs.com/apps/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "qwen-flash",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "qwen-max",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "qwen-max"
        ],
        icon: "OtherLogo"
    )

    static let modelScopeAI = ProviderTemplate(
        name: "ModelScope",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api-inference.modelscope.cn",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "Qwen/Qwen3-Coder-480B-A35B-Instruct",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-ai/DeepSeek-R1-0528"
        ],
        icon: "OtherLogo"
    )

    static let packyCodeAI = ProviderTemplate(
        name: "PackyCode",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.packycode.com",
            "ANTHROPIC_AUTH_TOKEN": "",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
        ],
        icon: "OtherLogo"
    )

    static let longCatAI = ProviderTemplate(
        name: "LongCat",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://api.longcat.chat/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "LongCat-Flash-Chat",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "LongCat-Flash-Chat",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "LongCat-Flash-Thinking",
            "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "6000",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
        ],
        icon: "OtherLogo"
    )

    static let anyRouterAI = ProviderTemplate(
        name: "AnyRouter",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://anyrouter.top",
            "ANTHROPIC_AUTH_TOKEN": ""
        ],
        icon: "OtherLogo"
    )

    static let vanchinAI = ProviderTemplate(
        name: "Vanchin",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://wanqing.streamlakeapi.com/api/gateway/v1/endpoints/xxx/claude-code-proxy",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "KAT-Coder",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "KAT-Coder",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "KAT-Coder"
        ],
        icon: "OtherLogo"
    )

    static let zenMuxAI = ProviderTemplate(
        name: "ZenMux",
        envVariables: [
            "ANTHROPIC_BASE_URL": "https://zenmux.ai/api/anthropic",
            "ANTHROPIC_AUTH_TOKEN": "",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "google/gemini-3-pro-preview-free",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "google/gemini-3-pro-preview-free",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "google/gemini-3-pro-preview-free",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
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
        .anthropic, .zhipuAI, .zai, .moonshotAI,
        .minimax, .miniMaxIo,
        .deepSeekAI, .aliyuncsAI, .modelScopeAI,
        .packyCodeAI, .longCatAI, .anyRouterAI,
        .vanchinAI, .zenMuxAI,
        .other
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
    case envVarPicker

    static func == (lhs: AppScreen, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.list, .list): return true
        case (.selectTemplate, .selectTemplate): return true
        case (.addForm(let a), .addForm(let b)): return a == b
        case (.edit(let a), .edit(let b)): return a == b
        case (.deleteConfirm(let a), .deleteConfirm(let b)): return a == b
        case (.envVarPicker, .envVarPicker): return true
        default: return false
        }
    }
}

// MARK: - ClaudeEnvCategory

enum ClaudeEnvCategory: CaseIterable {
    case apiAuthentication
    case modelConfiguration
    case bashConfiguration
    case claudeCodeConfiguration
    case featureToggles
    case proxyConfiguration
    case mcpConfiguration
    case thinkingConfiguration
    case miscellaneous

    var displayName: String {
        switch self {
        case .apiAuthentication:       return "API Auth"
        case .modelConfiguration:      return "Models"
        case .bashConfiguration:       return "Bash"
        case .claudeCodeConfiguration: return "Claude Code"
        case .featureToggles:          return "Features"
        case .proxyConfiguration:      return "Proxy"
        case .mcpConfiguration:        return "MCP"
        case .thinkingConfiguration:   return "Thinking"
        case .miscellaneous:           return "Misc"
        }
    }
}

// MARK: - ClaudeEnvVariable

struct ClaudeEnvVariable: Identifiable {
    let name: String
    let shortName: String
    let description: String
    let type: EnvValueType
    let defaultValue: String?
    let category: ClaudeEnvCategory

    var id: String { name }

    static let allVariables: [ClaudeEnvVariable] = [
        // API Authentication
        ClaudeEnvVariable(name: "ANTHROPIC_API_KEY",        shortName: "API Key",        description: "API key sent as X-Api-Key header",                          type: .string,  defaultValue: nil,     category: .apiAuthentication),
        ClaudeEnvVariable(name: "ANTHROPIC_AUTH_TOKEN",     shortName: "Auth Token",     description: "Custom value for Authorization header (Bearer prefix)",     type: .string,  defaultValue: nil,     category: .apiAuthentication),
        ClaudeEnvVariable(name: "ANTHROPIC_BASE_URL",       shortName: "Base URL",       description: "Base URL for API requests",                                 type: .string,  defaultValue: nil,     category: .apiAuthentication),
        ClaudeEnvVariable(name: "ANTHROPIC_CUSTOM_HEADERS", shortName: "Custom Headers", description: "Custom headers to add to requests (Name: Value format)",   type: .string,  defaultValue: nil,     category: .apiAuthentication),

        // Model Configuration
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_HAIKU_MODEL",       shortName: "Haiku Model",       description: "Default model name for Haiku",                          type: .string,  defaultValue: nil, category: .modelConfiguration),
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_OPUS_MODEL",        shortName: "Opus Model",        description: "Default model name for Opus",                           type: .string,  defaultValue: nil, category: .modelConfiguration),
        ClaudeEnvVariable(name: "ANTHROPIC_DEFAULT_SONNET_MODEL",      shortName: "Sonnet Model",      description: "Default model name for Sonnet",                         type: .string,  defaultValue: nil, category: .modelConfiguration),
        ClaudeEnvVariable(name: "ANTHROPIC_MODEL",                     shortName: "Model Setting",     description: "Model setting name to use",                             type: .string,  defaultValue: "default", category: .modelConfiguration),
        ClaudeEnvVariable(name: "ANTHROPIC_SMALL_FAST_MODEL",          shortName: "Small Fast Model",  description: "[Deprecated] Haiku-class model for background tasks",   type: .string,  defaultValue: nil, category: .modelConfiguration),
        ClaudeEnvVariable(name: "ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION", shortName: "Small Model Region", description: "Override AWS region for Haiku on Bedrock",          type: .string,  defaultValue: nil, category: .modelConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SUBAGENT_MODEL",          shortName: "Subagent Model",    description: "Model to use for subagents",                            type: .string,  defaultValue: nil, category: .modelConfiguration),

        // Bash Configuration
        ClaudeEnvVariable(name: "BASH_DEFAULT_TIMEOUT_MS",                 shortName: "Bash Default Timeout", description: "Default timeout for long-running bash commands",              type: .integer, defaultValue: nil,     category: .bashConfiguration),
        ClaudeEnvVariable(name: "BASH_MAX_OUTPUT_LENGTH",                  shortName: "Bash Max Output",      description: "Max characters in bash output before truncation",            type: .integer, defaultValue: nil,     category: .bashConfiguration),
        ClaudeEnvVariable(name: "BASH_MAX_TIMEOUT_MS",                     shortName: "Bash Max Timeout",     description: "Maximum timeout the model can set for bash commands",        type: .integer, defaultValue: nil,     category: .bashConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR", shortName: "Maintain Working Dir", description: "Return to original working dir after each Bash command",   type: .boolean, defaultValue: "false", category: .bashConfiguration),

        // Claude Code Configuration
        ClaudeEnvVariable(name: "API_TIMEOUT_MS",                          shortName: "API Timeout",            description: "API request timeout in milliseconds",                      type: .integer, defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_API_KEY_HELPER_TTL_MS",       shortName: "Key Refresh Interval",   description: "Credential refresh interval in milliseconds",              type: .integer, defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_CERT",                 shortName: "Client Certificate",     description: "Path to client certificate file for mTLS",                type: .string,  defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_KEY",                  shortName: "Client Key",             description: "Path to client private key file for mTLS",                type: .string,  defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_CLIENT_KEY_PASSPHRASE",       shortName: "Key Passphrase",         description: "Passphrase for encrypted private key",                     type: .string,  defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_BACKGROUND_TASKS",    shortName: "Disable Background",     description: "Disable all background task functionality",                type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS",  shortName: "Disable Betas",          description: "Disable Anthropic API-specific beta headers",              type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC", shortName: "Disable Traffic",       description: "Disable non-essential network traffic",                    type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_DISABLE_TERMINAL_TITLE",      shortName: "Disable Terminal Title", description: "Disable automatic terminal title updates",                 type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_ENABLE_TELEMETRY",            shortName: "Enable Telemetry",       description: "Enable telemetry collection",                              type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_FILE_READ_MAX_OUTPUT_TOKENS", shortName: "File Read Max Tokens",   description: "Override default token limit for file reads",              type: .integer, defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_HIDE_ACCOUNT_INFO",           shortName: "Hide Account Info",      description: "Hide email and organization name from UI",                 type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL",       shortName: "Skip IDE Auto Install",  description: "Skip auto-installation of IDE extensions",                 type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_MAX_OUTPUT_TOKENS",           shortName: "Max Output Tokens",      description: "Maximum output tokens for most requests",                  type: .integer, defaultValue: "4096",    category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SHELL",                       shortName: "Shell Override",         description: "Override automatic shell detection",                       type: .string,  defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_SHELL_PREFIX",                shortName: "Shell Prefix",           description: "Command prefix to wrap all bash commands",                 type: .string,  defaultValue: nil,       category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_USE_BEDROCK",                 shortName: "Use Bedrock",            description: "Use Amazon Bedrock",                                       type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CODE_USE_VERTEX",                  shortName: "Use Vertex",             description: "Use Google Vertex AI",                                     type: .boolean, defaultValue: "false",   category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_CONFIG_DIR",                       shortName: "Config Directory",       description: "Custom location for config and data files",                type: .string,  defaultValue: "~/.claude", category: .claudeCodeConfiguration),
        ClaudeEnvVariable(name: "CLAUDE_ENV_FILE",                         shortName: "Env File Path",          description: "File path for persisting env vars from SessionStart hooks", type: .string, defaultValue: nil,       category: .claudeCodeConfiguration),

        // Feature Toggles
        ClaudeEnvVariable(name: "DISABLE_AUTOUPDATER",              shortName: "Disable Auto Update",  description: "Disable automatic updates",                              type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_BUG_COMMAND",              shortName: "Disable Bug Command",  description: "Disable /bug command",                                   type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_COST_WARNINGS",            shortName: "Disable Cost Warnings", description: "Disable cost warning messages",                         type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_ERROR_REPORTING",          shortName: "Disable Error Report", description: "Opt out of Sentry error reporting",                      type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_NON_ESSENTIAL_MODEL_CALLS", shortName: "Disable Extra Calls", description: "Disable model calls for non-critical paths",             type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING",           shortName: "Disable Caching",      description: "Disable prompt caching for all models",                  type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_HAIKU",     shortName: "Disable Haiku Cache",  description: "Disable prompt caching for Haiku models",                type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_OPUS",      shortName: "Disable Opus Cache",   description: "Disable prompt caching for Opus models",                 type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_PROMPT_CACHING_SONNET",    shortName: "Disable Sonnet Cache", description: "Disable prompt caching for Sonnet models",               type: .boolean, defaultValue: "false", category: .featureToggles),
        ClaudeEnvVariable(name: "DISABLE_TELEMETRY",                shortName: "Disable Telemetry",    description: "Opt out of Statsig telemetry",                           type: .boolean, defaultValue: "false", category: .featureToggles),

        // Proxy Configuration
        ClaudeEnvVariable(name: "HTTP_PROXY",  shortName: "HTTP Proxy",   description: "HTTP proxy server",                       type: .string, defaultValue: nil, category: .proxyConfiguration),
        ClaudeEnvVariable(name: "HTTPS_PROXY", shortName: "HTTPS Proxy",  description: "HTTPS proxy server",                      type: .string, defaultValue: nil, category: .proxyConfiguration),
        ClaudeEnvVariable(name: "NO_PROXY",    shortName: "Proxy Bypass", description: "Domains and IPs to bypass proxy",         type: .string, defaultValue: nil, category: .proxyConfiguration),

        // MCP Configuration
        ClaudeEnvVariable(name: "MAX_MCP_OUTPUT_TOKENS", shortName: "MCP Max Tokens",    description: "Maximum tokens for MCP tool responses",              type: .integer, defaultValue: "25000", category: .mcpConfiguration),
        ClaudeEnvVariable(name: "MCP_TIMEOUT",           shortName: "MCP Startup Timeout", description: "Timeout in ms for MCP server startup",             type: .integer, defaultValue: nil,     category: .mcpConfiguration),
        ClaudeEnvVariable(name: "MCP_TOOL_TIMEOUT",      shortName: "MCP Tool Timeout",  description: "Timeout in ms for MCP tool execution",               type: .integer, defaultValue: nil,     category: .mcpConfiguration),

        // Thinking Configuration
        ClaudeEnvVariable(name: "MAX_THINKING_TOKENS", shortName: "Thinking Tokens", description: "Token budget for extended thinking process", type: .integer, defaultValue: "0", category: .thinkingConfiguration),

        // Miscellaneous
        ClaudeEnvVariable(name: "SLASH_COMMAND_TOOL_CHAR_BUDGET", shortName: "Command Char Budget", description: "Maximum characters for slash command metadata", type: .integer, defaultValue: "15000", category: .miscellaneous),
        ClaudeEnvVariable(name: "USE_BUILTIN_RIPGREP",            shortName: "Use Built-in RipGrep", description: "Use built-in rg instead of system-installed rg", type: .boolean, defaultValue: "true", category: .miscellaneous),
    ]

    static func variables(for category: ClaudeEnvCategory) -> [ClaudeEnvVariable] {
        allVariables.filter { $0.category == category }
    }
}

// MARK: - EnvValueType

enum EnvValueType {
    case string
    case integer
    case boolean
}
