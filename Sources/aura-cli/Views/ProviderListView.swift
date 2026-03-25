//
//  ProviderListView.swift
//  aura-cli
//
//  Created by PuerGozi
//

import Foundation
import SwiftTUI

struct ProviderListView: View {
    @ObservedObject var viewModel: AppViewModel
    // Tracks which provider is currently focused (via Button hover)
    @State private var hoveredIndex: Int = -1

    private var allProviders: [Provider] { viewModel.providers }

    var body: some View {
        VStack(alignment: .leading) {
            Text("aura-cli — Claude Code Provider Manager").bold()
            Text(String(repeating: "─", count: 46))
            // Default row
            Button(
                action: { viewModel.activateDefault() },
                hover: { hoveredIndex = -1 }
            ) {
                HStack {
                    Text(viewModel.isDefaultActive ? "● " : "  ")
                    Text("Default")
                    if viewModel.isDefaultActive { Text("  [active]") }
                }
            }
            // Provider rows
            ForEach(0..<allProviders.count, id: \.self) { i in
                let p = allProviders[i]
                Button(
                    action: { viewModel.activateProvider(p) },
                    hover: { hoveredIndex = i }
                ) {
                    HStack {
                        Text(viewModel.isActive(p) ? "● " : "  ")
                        Text(p.name)
                        if viewModel.isActive(p) { Text("  [active]") }
                    }
                }
            }
            Text(String(repeating: "─", count: 46))
            statusLine
            actionRow
        }
        .padding()
    }

    @ViewBuilder
    private var statusLine: some View {
        if !viewModel.statusMessage.isEmpty {
            Text(viewModel.statusMessage)
        } else {
            Text(" ")
        }
    }

    private var actionRow: some View {
        HStack {
            Button("[Add]") {
                viewModel.navigate(to: .selectTemplate)
            }
            Button("[Edit]") {
                editHovered()
            }
            Button("[Delete]") {
                deleteHovered()
            }
            Button("[Quit]") {
                exit(0)
            }
        }
    }

    private func editHovered() {
        if hoveredIndex >= 0 && hoveredIndex < allProviders.count {
            viewModel.navigate(to: .edit(allProviders[hoveredIndex]))
        }
    }

    private func deleteHovered() {
        if hoveredIndex >= 0 && hoveredIndex < allProviders.count {
            viewModel.navigate(to: .deleteConfirm(allProviders[hoveredIndex]))
        }
    }
}
