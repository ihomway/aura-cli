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

    // MARK: - List screen state

    /// 0 = Default row, 1..n = providers[i-1]
    private var listIndex: Int = 0

    // MARK: - Template-select screen state

    private let templates = ProviderTemplate.allTemplates
    private var templateIndex: Int = 0

    // MARK: - Form screen state  (shared for add / edit)

    /// 0 name, 1 url, 2 token, 3 haiku, 4 sonnet, 5 opus, 6 [Save], 7 [Back]
    private var formFieldIndex: Int = 0
    private var formValues: [String] = Array(repeating: "", count: 6)

    // MARK: - Delete-confirm screen state

    /// 0 = [Yes, Delete], 1 = [Cancel]
    private var deleteActionIndex: Int = 0

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
            exit(0)
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
        "Haiku: ", "Sonnet:", "Opus:  "
    ]

    func loadFormForAdd(template: ProviderTemplate) {
        formFieldIndex = 0
        formValues[0] = template.name
        formValues[1] = template.envVariables["ANTHROPIC_BASE_URL"] ?? ""
        formValues[2] = ""
        formValues[3] = template.envVariables["ANTHROPIC_DEFAULT_HAIKU_MODEL"] ?? ""
        formValues[4] = template.envVariables["ANTHROPIC_DEFAULT_SONNET_MODEL"] ?? ""
        formValues[5] = template.envVariables["ANTHROPIC_DEFAULT_OPUS_MODEL"] ?? ""
    }

    func loadFormForEdit(provider: Provider) {
        formFieldIndex = 0
        formValues[0] = provider.name
        formValues[1] = provider.envVariables["ANTHROPIC_BASE_URL"] ?? ""
        formValues[2] = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
        formValues[3] = provider.envVariables["ANTHROPIC_DEFAULT_HAIKU_MODEL"] ?? ""
        formValues[4] = provider.envVariables["ANTHROPIC_DEFAULT_SONNET_MODEL"] ?? ""
        formValues[5] = provider.envVariables["ANTHROPIC_DEFAULT_OPUS_MODEL"] ?? ""
    }

    func renderForm(width: Int, title: String) -> [String] {
        let sep = String(repeating: "─", count: min(width - 4, 46))
        var lines: [String] = []
        lines.append("  \(title)")
        lines.append("  \(sep)")

        for i in 0..<6 {
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

        lines.append("  \(sep)")

        if let warning = viewModel.duplicateWarning {
            let ctx = warning.kind == .sameURL ? "same URL" : "different URL"
            lines.append("  ⚠  Token used by '\(warning.existingProvider.name)' (\(ctx)).")
            lines.append("  ↑↓ navigate  type to edit  Backspace delete  Enter next")
        } else {
            lines.append("  ↑↓ navigate  type to edit  Backspace delete  Enter next")
        }

        let saveCursor = formFieldIndex == 6 ? ">" : " "
        let backCursor = formFieldIndex == 7 ? ">" : " "
        lines.append("  \(saveCursor) [Save]   \(backCursor) [Back]")
        return lines
    }

    func handleForm(input: TerminalInput) {
        switch input {
        case .key(.arrowUp, _):
            if formFieldIndex > 0 { formFieldIndex -= 1 }
            requestRender()
        case .key(.arrowDown, _), .key(.tab, _):
            if formFieldIndex < 7 { formFieldIndex += 1 }
            requestRender()
        case .key(.enter, _):
            if formFieldIndex < 5 {
                formFieldIndex += 1
                requestRender()
            } else if formFieldIndex == 5 {
                formFieldIndex = 6
                requestRender()
            } else if formFieldIndex == 6 {
                submitForm()
            } else {
                navigateBack()
            }
        case .key(.backspace, _), .key(.delete, _):
            if formFieldIndex < 6 && !formValues[formFieldIndex].isEmpty {
                formValues[formFieldIndex].removeLast()
                requestRender()
            }
        case .key(.escape, _):
            if viewModel.duplicateWarning != nil {
                viewModel.dismissDuplicateWarning()
            } else {
                navigateBack()
            }
        case .key(.character(let c), _) where formFieldIndex < 6:
            formValues[formFieldIndex].append(c)
            requestRender()
        case .paste(let text) where formFieldIndex < 6:
            let sanitized = text
                .replacingOccurrences(of: "\r\n", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
            formValues[formFieldIndex] += sanitized
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
