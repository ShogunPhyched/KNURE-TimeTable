//
//  AddItemsListView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 27.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct AddItemsListView: View {

	@Binding var path: [String]

	@State private var searchText = ""
	@State private var viewModel: [AddItemsListView.Section] = []
	@State private var isErrorOccured: Bool = false
	@State private var error: Error?

	private var filtredViewModels: [AddItemsListView.Section] {
		if searchText.isEmpty {
			return viewModel
		} else {
			return viewModel.compactMap { entry in
				var entry = entry
				entry.models = entry.models.filter {
					$0.title.localizedCaseInsensitiveContains(searchText)
				}
				return entry.models.isEmpty ? nil : entry
			}
		}
	}

	let interactor: AddItemsInteractor
	let itemType: Item.Kind

	var body: some View {
		ZStack {
			if viewModel.isEmpty {
				ProgressView()
					.controlSize(.large)
			}
			List(filtredViewModels) { record in
				SwiftUI.Section(record.title) {
					ForEach(record.models) { model in
						Button {
							guard !model.selected else { return }
							Task {
								try await interactor.save(item: model.item)
								path.removeAll()
							}
						} label: {
							AddItemCell(model: .init(title: model.title, selected: model.selected))
						}
					}
				}
				.font(.headline)
			}
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
			.navigationTitle("Add \(itemType.presentationValue)")
			.toolbarRole(.editor)
			.listStyle(.plain)
			.task {
				do {
					viewModel = try await interactor.obtainItems(kind: itemType)
				} catch {
					isErrorOccured = true
					self.error = error
				}
			}
			.alert("An Error has occured", isPresented: $isErrorOccured, actions: {
				Button(role: .cancel) {
					isErrorOccured = false
				} label: {
					Text("Ok")
				}
			}, message: {
				Text(error?.localizedDescription ?? "")
			})
		}
	}
}

extension AddItemsListView {

	struct Section: Identifiable, Hashable {
		var id: String { models.map(\.id).joined() }
		let title: String
		var models: [AddItemsListView.Model]
	}

	struct Model: Identifiable, Sendable, Hashable {
		var id: String { String(item.identifier) }
		let title: String
		let selected: Bool

		let item: Item
	}
}
