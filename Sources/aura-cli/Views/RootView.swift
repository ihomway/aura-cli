//
//  RootView.swift
//  aura-cli
//
//  Created by PuerGozi
//

import SwiftTUI

struct RootView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        if case .list = viewModel.currentScreen {
            ProviderListView(viewModel: viewModel)
        } else if case .selectTemplate = viewModel.currentScreen {
            SelectTemplateView(viewModel: viewModel)
        } else if case .addForm(let template) = viewModel.currentScreen {
            AddProviderFormView(viewModel: viewModel, template: template)
        } else if case .edit(let provider) = viewModel.currentScreen {
            EditProviderView(viewModel: viewModel, provider: provider)
        } else if case .deleteConfirm(let provider) = viewModel.currentScreen {
            DeleteConfirmView(viewModel: viewModel, provider: provider)
        } else {
            ProviderListView(viewModel: viewModel)
        }
    }
}
