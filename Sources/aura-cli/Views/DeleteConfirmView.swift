//
//  DeleteConfirmView.swift
//  aura-cli
//
//  Created by PuerGozi
//

import SwiftTUI

struct DeleteConfirmView: View {
    @ObservedObject var viewModel: AppViewModel
    let provider: Provider

    var body: some View {
        VStack(alignment: .leading) {
            Text("Delete Provider").bold()
            Text(String(repeating: "─", count: 46))
            Text("Delete '\(provider.name)'?")
            Text("")
            HStack {
                Button("[Yes, Delete]") {
                    viewModel.deleteProvider(provider)
                }
                Button("[Cancel]") {
                    viewModel.navigate(to: .list)
                }
            }
        }
        .padding()
    }
}
