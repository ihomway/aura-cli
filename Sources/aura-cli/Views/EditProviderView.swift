//
//  EditProviderView.swift
//  aura-cli
//
//  Created by PuerGozi
//

import SwiftTUI

struct EditProviderView: View {
    @ObservedObject var viewModel: AppViewModel
    let provider: Provider

    @State private var pendingName: String = ""
    @State private var pendingURL: String = ""
    @State private var pendingToken: String = ""
    @State private var pendingHaiku: String = ""
    @State private var pendingSonnet: String = ""
    @State private var pendingOpus: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Provider: \(provider.name)").bold()
            Text(String(repeating: "─", count: 46))
            connectionFields
            modelFields
            Text(String(repeating: "─", count: 46))
            hintOrWarning
            actionButtons
        }
        .padding()
        .onAppear {
            pendingName = provider.name
            pendingURL = provider.envVariables["ANTHROPIC_BASE_URL"] ?? ""
            pendingToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"] ?? ""
            pendingHaiku = provider.envVariables["ANTHROPIC_DEFAULT_HAIKU_MODEL"] ?? ""
            pendingSonnet = provider.envVariables["ANTHROPIC_DEFAULT_SONNET_MODEL"] ?? ""
            pendingOpus = provider.envVariables["ANTHROPIC_DEFAULT_OPUS_MODEL"] ?? ""
        }
    }

    private var connectionFields: some View {
        VStack(alignment: .leading) {
            Text("Name:   \(pendingName)")
            TextField(placeholder: "type new name, Enter to set") { pendingName = $0 }
            Text("URL:    \(pendingURL)")
            TextField(placeholder: "type new URL, Enter to set") { pendingURL = $0 }
            Text("Token:  \(maskedToken)")
            TextField(placeholder: "type new token, Enter to set") { pendingToken = $0 }
        }
    }

    private var modelFields: some View {
        VStack(alignment: .leading) {
            Text("Haiku:  \(pendingHaiku)")
            TextField(placeholder: "type Haiku model, Enter to set") { pendingHaiku = $0 }
            Text("Sonnet: \(pendingSonnet)")
            TextField(placeholder: "type Sonnet model, Enter to set") { pendingSonnet = $0 }
            Text("Opus:   \(pendingOpus)")
            TextField(placeholder: "type Opus model, Enter to set") { pendingOpus = $0 }
        }
    }

    private var maskedToken: String {
        pendingToken.isEmpty ? "(not set)" : String(repeating: "●", count: min(pendingToken.count, 12))
    }

    @ViewBuilder
    private var hintOrWarning: some View {
        if viewModel.duplicateWarning != nil {
            Text(duplicateWarningText)
            HStack {
                Button("[Save anyway]") { saveAnyway() }
                Button("[Cancel]") { viewModel.dismissDuplicateWarning() }
            }
        } else {
            Text("Fill each field and press Enter to set, then [Save].")
        }
    }

    private var duplicateWarningText: String {
        guard let w = viewModel.duplicateWarning else { return "" }
        let ctx = w.kind == .sameURL ? "same URL" : "different URL"
        return "⚠  Token already used by '\(w.existingProvider.name)' (\(ctx))."
    }

    private var actionButtons: some View {
        HStack {
            Button("[Save]") { handleSave() }
            Button("[Cancel]") { viewModel.navigate(to: .list) }
        }
    }

    private func buildEnvVars() -> [String: String] {
        var env: [String: String] = [:]
        env["ANTHROPIC_BASE_URL"] = pendingURL
        env["ANTHROPIC_AUTH_TOKEN"] = pendingToken
        if !pendingHaiku.isEmpty { env["ANTHROPIC_DEFAULT_HAIKU_MODEL"] = pendingHaiku }
        if !pendingSonnet.isEmpty { env["ANTHROPIC_DEFAULT_SONNET_MODEL"] = pendingSonnet }
        if !pendingOpus.isEmpty { env["ANTHROPIC_DEFAULT_OPUS_MODEL"] = pendingOpus }
        return env
    }

    private func handleSave() {
        let env = buildEnvVars()
        let icon = ProviderStore.inferIcon(from: pendingURL)
        viewModel.submitEditProvider(
            id: provider.id,
            name: pendingName,
            envVariables: env,
            icon: icon,
            wasActive: viewModel.isActive(provider)
        )
    }

    private func saveAnyway() {
        let env = buildEnvVars()
        let icon = ProviderStore.inferIcon(from: pendingURL)
        viewModel.commitEditProvider(
            id: provider.id,
            name: pendingName,
            envVariables: env,
            icon: icon,
            wasActive: viewModel.isActive(provider)
        )
    }
}
