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
	@State private var viewModel: [AddItemsListView.Model] = []
	@State private var isErrorOccured: Bool = false

	let interactor: AddItemsInteractor
	let itemType: Item.Kind

	var body: some View {
		ZStack {
			if viewModel.isEmpty {
				ProgressView()
					.controlSize(.large)
			}
			List(viewModel) { record in
				Button {
					guard !record.selected else { return }
					Task {
						try await interactor.save(item: record.item)
						path.removeAll()
					}
				} label: {
					AddItemCell(model: .init(title: record.title, selected: record.selected))
				}
			}
			.navigationTitle("Add Items List")
			.listStyle(.plain)
			.task {
				do {
					viewModel = try await interactor.obtainItems(kind: itemType)
				} catch {
					isErrorOccured = true
				}
			}
			.searchable(text: $searchText)
			.alert("An Error has occured", isPresented: $isErrorOccured) {
				Button(role: .cancel) {
					isErrorOccured = false
				} label: {
					Text("Ok")
				}
			}
		}
	}
}

extension AddItemsListView {

	struct Model: Identifiable, Sendable, Hashable {
		var id: String { String(item.identifier) }
		let title: String
		let selected: Bool

		let item: Item
	}
}
