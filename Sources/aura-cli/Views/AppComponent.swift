//
//  AppComponent.swift
//  aura-cli
//
//  Central TauTUI component that drives all aura-cli screens.
//  Implements the Component protocol and delegates business logic to AppViewModel.
//

import TauTUI
import Foundation

final class AppComponent: Component {

    // MARK: - Dependencies

    let viewModel: AppViewModel
    /// Set by main.swift after TUI is created; called when local UI state changes.
    var requestRender: () -> Void = {}
    /// Set by main.swift; calls tui.stop() then exit(0) to restore terminal before quitting.
    var onQuit: () -> Void = { exit(0) }

    // MARK: - List screen state

    /// 0 = Default row, 1..n = providers[i-1]
    private var listIndex: Int = 0

    // MARK: - Template-select screen state

    private let templates = ProviderTemplate.allTemplates
    private var templateIndex: Int = 0

    // MARK: - Form screen state  (shared for add / edit)

    /// Indices 0–7: name, url, token, haiku, sonnet, opus, disable_traffic, timeout.
    /// Indices 8...(8+extraEnvVars.count-1): extra env-var value fields.
    /// addEnvVarIndex: [+ Add env var] button.
    /// saveIndex: [Save]. backIndex: [Back].
    private var formFieldIndex: Int = 0
    private var formValues: [String] = Array(repeating: "", count: 8)

    /// Extra env variables beyond the 8 core fields.
    private var extraEnvVars: [(key: String, value: String)] = []

    private var addEnvVarIndex: Int { 8 + extraEnvVars.count }
    private var saveIndex: Int      { 8 + extraEnvVars.count + 1 }
    private var backIndex: Int      { 8 + extraEnvVars.count + 2 }

    /// Core env-var keys always shown as the 7 dedicated form fields.
    private static let coreEnvVarKeys: Set<String> = [
        "ANTHROPIC_BASE_URL",
        "ANTHROPIC_AUTH_TOKEN",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL",
        "ANTHROPIC_DEFAULT_SONNET_MODEL",
        "ANTHROPIC_DEFAULT_OPUS_MODEL",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC",
        "API_TIMEOUT_MS"
    ]

    // MARK: - Delete-confirm screen state

    /// 0 = [Yes, Delete], 1 = [Cancel]
    private var deleteActionIndex: Int = 0

    // MARK: - Env-var picker screen state

    private var pickerCategoryIndex: Int = 0
    private var pickerItemIndex: Int = 0
    private var pickerOriginScreen: AppScreen = .list

    // MARK: - Init

    init(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Component: render

    func render(width: Int) -> [String] {
        switch viewModel.currentScreen {
        case .list:
            return renderList(width: width)
        case .selectTemplate:
            return renderSelectTemplate(width: width)
        case .addForm(let template):
            return renderForm(width: width, title: "Add Provider: \(template.name)")
        case .edit(let provider):
            return renderForm(width: width, title: "Edit Provider: \(provider.name)")
        case .deleteConfirm(let provider):
            return renderDeleteConfirm(width: width, provider: provider)
        case .envVarPicker:
            return renderEnvVarPicker(width: width)
        }
    }

    // MARK: - Component: handle input

    func handle(input: TerminalInput) {
        switch viewModel.currentScreen {
        case .list:
            handleList(input: input)
        case .selectTemplate:
            handleSelectTemplate(input: input)
        case .addForm:
            handleForm(input: input)
        case .edit:
            handleForm(input: input)
        case .deleteConfirm(let provider):
            handleDeleteConfirm(input: input, provider: provider)
        case .envVarPicker:
            handleEnvVarPicker(input: input)
        }
    }
}

// MARK: - Provider List Screen

private extension AppComponent {

    func renderList(width: Int) -> [String] {
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  aura-cli — Claude Code Provider Manager")
        lines.append("  \(sep)")

        // Default row (listIndex == 0)
        let defaultDot = viewModel.isDefaultActive ? "●" : "○"
        let defaultCursor = listIndex == 0 ? ">" : " "
        var defaultRow = "  \(defaultCursor) \(defaultDot) Default"
        if viewModel.isDefaultActive { defaultRow += "  [active]" }
        lines.append(defaultRow)

        // Provider rows
        for (i, p) in viewModel.providers.enumerated() {
            let dot = viewModel.isActive(p) ? "●" : "○"
            let cursor = listIndex == i + 1 ? ">" : " "
            var row = "  \(cursor) \(dot) \(p.name)"
            if viewModel.isActive(p) { row += "  [active]" }
            lines.append(row)
        }

        lines.append("  \(sep)")

        if !viewModel.statusMessage.isEmpty {
            lines.append("  \(viewModel.statusMessage)")
        } else {
            lines.append("")
        }
        lines.append("  ↑↓ navigate  Enter activate  [a]dd  [e]dit  [d]elete  [q]uit")
        return lines
    }

    func handleList(input: TerminalInput) {
        let total = viewModel.providers.count + 1
        switch input {
        case .key(.arrowUp, _):
            if listIndex > 0 { listIndex -= 1 }
            requestRender()
        case .key(.arrowDown, _):
            if listIndex < total - 1 { listIndex += 1 }
            requestRender()
        case .key(.enter, _):
            activateListSelection()
        case .key(.character("a"), _):
            templateIndex = 0
            viewModel.navigate(to: .selectTemplate)
        case .key(.character("e"), _):
            editListSelection()
        case .key(.character("d"), _):
            deleteListSelection()
        case .key(.character("q"), _):
            onQuit()
        default:
            break
        }
    }

    func activateListSelection() {
        if listIndex == 0 {
            viewModel.activateDefault()
        } else {
            let p = viewModel.providers[listIndex - 1]
            viewModel.activateProvider(p)
        }
    }

    func editListSelection() {
        guard listIndex > 0 else { return }
        let p = viewModel.providers[listIndex - 1]
        loadFormForEdit(provider: p)
        viewModel.navigate(to: .edit(p))
    }

    func deleteListSelection() {
        guard listIndex > 0 else { return }
        let p = viewModel.providers[listIndex - 1]
        deleteActionIndex = 0
        viewModel.navigate(to: .deleteConfirm(p))
    }
}

// MARK: - Template-Select Screen

private extension AppComponent {

    func renderSelectTemplate(width: Int) -> [String] {
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  Add Provider — Select a Template")
        lines.append("  \(sep)")
        for (i, t) in templates.enumerated() {
            let cursor = templateIndex == i ? ">" : " "
            lines.append("  \(cursor) \(t.name)")
        }
        lines.append("  \(sep)")
        lines.append("  ↑↓ navigate  Enter select  Esc back")
        return lines
    }

    func handleSelectTemplate(input: TerminalInput) {
        switch input {
        case .key(.arrowUp, _):
            if templateIndex > 0 { templateIndex -= 1 }
            requestRender()
        case .key(.arrowDown, _):
            if templateIndex < templates.count - 1 { templateIndex += 1 }
            requestRender()
        case .key(.enter, _):
            let template = templates[templateIndex]
            loadFormForAdd(template: template)
            viewModel.navigate(to: .addForm(template))
        case .key(.escape, _):
            viewModel.navigate(to: .list)
        default:
            break
        }
    }
}

// MARK: - Add / Edit Form Screen

private extension AppComponent {

    private static let fieldLabels = [
        "Name:  ", "URL:   ", "Token: ",
        "Haiku: ", "Sonnet:", "Opus:  ",
        "NoTraf:", "Tmout: "
    ]

    func loadFormForAdd(template: ProviderTemplate) {
        formFieldIndex = 0
        formValues[0] = template.name
        formValues[1] = template.envVariables["ANTHROPIC_BASE_URL"] ?? ""
        formValues[2] = ""
        formValues[3] = template.envVariables["ANTHROPIC_DEFAULT_HAIKU_MODEL"] ?? ""
        formValues[4] = template.envVariables["ANTHROPIC_DEFAULT_SONNET_MODEL"] ?? ""
        formValues[5] = template.envVariables["ANTHROPIC_DEFAULT_OPUS_MODEL"] ?? ""
        formValues[6] = template.envVariables["CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"] ?? ""
        formValues[7] = template.envVariables["API_TIMEOUT_MS"] ?? ""
        // Load any template env vars beyond the 8 core fields
        extraEnvVars = template.envVariables
            .filter { !Self.coreEnvVarKeys.contains($0.key) }
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, value: $0.value) }
    }

    func loadFormForEdit(provider: Provider) {
        formFieldIndex = 0
        formValues[0] = provider.name
        formValues[1] = provider.envVariables["ANTHROPIC_BASE_URL"] ?? ""
        formValues[2] = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
        formValues[3] = provider.envVariables["ANTHROPIC_DEFAULT_HAIKU_MODEL"] ?? ""
        formValues[4] = provider.envVariables["ANTHROPIC_DEFAULT_SONNET_MODEL"] ?? ""
        formValues[5] = provider.envVariables["ANTHROPIC_DEFAULT_OPUS_MODEL"] ?? ""
        formValues[6] = provider.envVariables["CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"] ?? ""
        formValues[7] = provider.envVariables["API_TIMEOUT_MS"] ?? ""
        // Populate extra vars from keys beyond the core 7 env-var keys
        extraEnvVars = provider.envVariables
            .filter { !Self.coreEnvVarKeys.contains($0.key) }
            .sorted { $0.key < $1.key }
            .map { (key: $0.key, value: $0.value) }
    }

    func renderForm(width: Int, title: String) -> [String] {
        let maxW = width - 6
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  \(title)")
        lines.append("  \(sep)")

        // Core 8 fields
        for i in 0..<8 {
            let label = Self.fieldLabels[i]
            let isFocused = formFieldIndex == i
            let cursor = isFocused ? ">" : " "
            let display: String
            if i == 2 {
                let v = formValues[2]
                display = v.isEmpty ? "(not set)" : String(repeating: "●", count: min(v.count, 20))
            } else {
                display = formValues[i]
            }
            let suffix = isFocused ? "▌" : ""
            lines.append("  \(cursor) \(label) \(display)\(suffix)")
        }

        // Extra env-var fields
        for (i, ev) in extraEnvVars.enumerated() {
            let fieldIdx = 8 + i
            let isFocused = formFieldIndex == fieldIdx
            let cursor = isFocused ? ">" : " "
            let keyDisplay = ev.key.count > maxW - 12 ? String(ev.key.prefix(maxW - 12)) + "…" : ev.key
            let suffix = isFocused ? "▌" : ""
            lines.append("  \(cursor) \(keyDisplay): \(ev.value)\(suffix)")
        }

        lines.append("  \(sep)")

        if let warning = viewModel.duplicateWarning {
            let ctx = warning.kind == .sameURL ? "same URL" : "different URL"
            lines.append("  ⚠  Token used by '\(warning.existingProvider.name)' (\(ctx)).")
            lines.append("  ↑↓ navigate  type to edit  Backspace delete  Enter next")
        } else {
            lines.append("  ↑↓ navigate  type to edit  Backspace delete  Enter next")
        }

        let addCursor  = formFieldIndex == addEnvVarIndex ? ">" : " "
        let saveCursor = formFieldIndex == saveIndex ? ">" : " "
        let backCursor = formFieldIndex == backIndex ? ">" : " "
        lines.append("  \(addCursor) [+ Add env var]")
        lines.append("  \(saveCursor) [Save]   \(backCursor) [Back]")
        return lines
    }

    func handleForm(input: TerminalInput) {
        switch input {
        case .key(.arrowUp, _):
            if formFieldIndex > 0 { formFieldIndex -= 1 }
            requestRender()
        case .key(.arrowDown, _), .key(.tab, _):
            if formFieldIndex < backIndex { formFieldIndex += 1 }
            requestRender()
        case .key(.enter, _):
            if formFieldIndex < 7 {
                formFieldIndex += 1
                requestRender()
            } else if formFieldIndex == 7 {
                formFieldIndex = 8
                requestRender()
            } else if formFieldIndex < addEnvVarIndex {
                // On an extra field — advance to next
                formFieldIndex += 1
                requestRender()
            } else if formFieldIndex == addEnvVarIndex {
                // Open the env-var picker
                pickerOriginScreen = viewModel.currentScreen
                pickerCategoryIndex = 0
                pickerItemIndex = 0
                viewModel.navigate(to: .envVarPicker)
            } else if formFieldIndex == saveIndex {
                submitForm()
            } else {
                navigateBack()
            }
        case .key(.backspace, _), .key(.delete, _):
            if formFieldIndex < 8 {
                if !formValues[formFieldIndex].isEmpty {
                    formValues[formFieldIndex].removeLast()
                    requestRender()
                }
            } else if formFieldIndex >= 8 && formFieldIndex < addEnvVarIndex {
                let extraIdx = formFieldIndex - 8
                if !extraEnvVars[extraIdx].value.isEmpty {
                    extraEnvVars[extraIdx].value.removeLast()
                    requestRender()
                } else {
                    extraEnvVars.remove(at: extraIdx)
                    if formFieldIndex > 0 { formFieldIndex -= 1 }
                    requestRender()
                }
            }
        case .key(.escape, _):
            if viewModel.duplicateWarning != nil {
                viewModel.dismissDuplicateWarning()
            } else {
                navigateBack()
            }
        case .key(.character(let c), _) where formFieldIndex < addEnvVarIndex:
            if formFieldIndex < 8 {
                formValues[formFieldIndex].append(c)
            } else {
                let extraIdx = formFieldIndex - 8
                extraEnvVars[extraIdx].value.append(c)
            }
            requestRender()
        case .paste(let text) where formFieldIndex < addEnvVarIndex:
            let sanitized = text
                .replacingOccurrences(of: "\r\n", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
            if formFieldIndex < 8 {
                formValues[formFieldIndex] += sanitized
            } else {
                let extraIdx = formFieldIndex - 8
                extraEnvVars[extraIdx].value += sanitized
            }
            requestRender()
        default:
            break
        }
    }

    func buildEnvVars() -> [String: String] {
        var env: [String: String] = [:]
        env["ANTHROPIC_BASE_URL"] = formValues[1]
        env["ANTHROPIC_AUTH_TOKEN"] = formValues[2]
        if !formValues[3].isEmpty { env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = formValues[3] }
        if !formValues[4].isEmpty { env["ANTHROPIC_DEFAULT_SONNET_MODEL"] = formValues[4] }
        if !formValues[5].isEmpty { env["ANTHROPIC_DEFAULT_OPUS_MODEL"] = formValues[5] }
        if !formValues[6].isEmpty { env["CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"] = formValues[6] }
        if !formValues[7].isEmpty { env["API_TIMEOUT_MS"] = formValues[7] }
        for ev in extraEnvVars where !ev.key.isEmpty {
            env[ev.key] = ev.value
        }
        return env
    }

    func submitForm() {
        let env = buildEnvVars()
        let icon = ProviderStore.inferIcon(from: formValues[1])
        switch viewModel.currentScreen {
        case .addForm:
            viewModel.submitNewProvider(name: formValues[0], envVariables: env, icon: icon)
        case .edit(let provider):
            viewModel.submitEditProvider(
                id: provider.id,
                name: formValues[0],
                envVariables: env,
                icon: icon,
                wasActive: viewModel.isActive(provider)
            )
        default:
            break
        }
    }

    func saveFormAnyway() {
        let env = buildEnvVars()
        let icon = ProviderStore.inferIcon(from: formValues[1])
        switch viewModel.currentScreen {
        case .addForm:
            viewModel.commitAddProvider(name: formValues[0], envVariables: env, icon: icon)
        case .edit(let provider):
            viewModel.commitEditProvider(
                id: provider.id,
                name: formValues[0],
                envVariables: env,
                icon: icon,
                wasActive: viewModel.isActive(provider)
            )
        default:
            break
        }
    }

    func navigateBack() {
        switch viewModel.currentScreen {
        case .addForm:
            viewModel.navigate(to: .selectTemplate)
        default:
            viewModel.navigate(to: .list)
        }
    }
}

// MARK: - Env-Var Picker Screen

private extension AppComponent {

    private static let pickerCategories = ClaudeEnvCategory.allCases

    /// Keys already configured in the form (core + extra).
    private var presentEnvVarKeys: Set<String> {
        var keys = Self.coreEnvVarKeys
        extraEnvVars.forEach { keys.insert($0.key) }
        return keys
    }

    func renderEnvVarPicker(width: Int) -> [String] {
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  Add Env Variable — Select Category & Key")
        lines.append("  \(sep)")

        // Tab bar: category names, selected wrapped in [...]
        let tabBar = Self.pickerCategories.enumerated().map { idx, cat in
            idx == pickerCategoryIndex ? "[\(cat.displayName)]" : cat.displayName
        }.joined(separator: "  ")
        lines.append("  \(tabBar)")
        lines.append("  \(sep)")

        // Items for current category
        let category = Self.pickerCategories[pickerCategoryIndex]
        let vars = ClaudeEnvVariable.variables(for: category)
        let present = presentEnvVarKeys
        let maxKeyW = max(10, min(width - 30, 42))

        for (i, variable) in vars.enumerated() {
            let isFocused = pickerItemIndex == i
            let isPresent = present.contains(variable.name)
            let cursor = isFocused ? ">" : " "
            let keyDisplay: String
            if variable.name.count > maxKeyW {
                keyDisplay = String(variable.name.prefix(maxKeyW)) + "…"
            } else {
                keyDisplay = variable.name.padding(toLength: maxKeyW, withPad: " ", startingAt: 0)
            }
            let descMaxW = max(10, width - maxKeyW - 8)
            let descDisplay: String
            if variable.shortName.count > descMaxW {
                descDisplay = String(variable.shortName.prefix(descMaxW)) + "…"
            } else {
                descDisplay = variable.shortName
            }
            let marker = isPresent ? "·" : " "
            lines.append("  \(cursor) \(marker) \(keyDisplay)  \(descDisplay)")
        }

        if vars.isEmpty {
            lines.append("  (no variables in this category)")
        }

        lines.append("  \(sep)")
        lines.append("  ←→ category  ↑↓ item  Enter add  Esc cancel  · = already set")
        return lines
    }

    func handleEnvVarPicker(input: TerminalInput) {
        let categories = Self.pickerCategories
        switch input {
        case .key(.arrowLeft, _):
            if pickerCategoryIndex > 0 {
                pickerCategoryIndex -= 1
                pickerItemIndex = 0
            }
            requestRender()
        case .key(.arrowRight, _):
            if pickerCategoryIndex < categories.count - 1 {
                pickerCategoryIndex += 1
                pickerItemIndex = 0
            }
            requestRender()
        case .key(.arrowUp, _):
            if pickerItemIndex > 0 { pickerItemIndex -= 1 }
            requestRender()
        case .key(.arrowDown, _):
            let vars = ClaudeEnvVariable.variables(for: categories[pickerCategoryIndex])
            if pickerItemIndex < vars.count - 1 { pickerItemIndex += 1 }
            requestRender()
        case .key(.enter, _):
            let vars = ClaudeEnvVariable.variables(for: categories[pickerCategoryIndex])
            guard !vars.isEmpty, pickerItemIndex < vars.count else { break }
            let variable = vars[pickerItemIndex]
            guard !presentEnvVarKeys.contains(variable.name) else { break }
            let defaultVal = variable.defaultValue ?? ""
            extraEnvVars.append((key: variable.name, value: defaultVal))
            formFieldIndex = addEnvVarIndex - 1  // focus the newly added field
            viewModel.navigate(to: pickerOriginScreen)
        case .key(.escape, _):
            viewModel.navigate(to: pickerOriginScreen)
        default:
            break
        }
    }
}

// MARK: - Delete-Confirm Screen

private extension AppComponent {

    func renderDeleteConfirm(width: Int, provider: Provider) -> [String] {
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  Delete Provider")
        lines.append("  \(sep)")
        lines.append("  Delete '\(provider.name)'?")
        lines.append("")
        let deleteCursor = deleteActionIndex == 0 ? ">" : " "
        let cancelCursor = deleteActionIndex == 1 ? ">" : " "
        lines.append("  \(deleteCursor) [Yes, Delete]   \(cancelCursor) [Cancel]")
        lines.append("")
        lines.append("  ←→ navigate  Enter confirm  Esc cancel")
        return lines
    }

    func handleDeleteConfirm(input: TerminalInput, provider: Provider) {
        switch input {
        case .key(.arrowLeft, _), .key(.arrowUp, _):
            deleteActionIndex = 0
            requestRender()
        case .key(.arrowRight, _), .key(.arrowDown, _):
            deleteActionIndex = 1
            requestRender()
        case .key(.enter, _):
            if deleteActionIndex == 0 {
                viewModel.deleteProvider(provider)
            } else {
                viewModel.navigate(to: .list)
            }
        case .key(.escape, _):
            viewModel.navigate(to: .list)
        case .key(.character("y"), _):
            viewModel.deleteProvider(provider)
        case .key(.character("n"), _):
            viewModel.navigate(to: .list)
        default:
            break
        }
    }
}
