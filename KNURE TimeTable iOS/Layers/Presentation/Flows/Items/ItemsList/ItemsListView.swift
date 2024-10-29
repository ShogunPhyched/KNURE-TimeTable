//
//  ItemsListView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 26.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct ItemsListView: View {

	@State private var viewModel: [ItemsListView.Model] = []
	@State private var path: [String] = []

	let interactor: ItemsListInteractorInput

	var body: some View {
		NavigationStack(path: $path) {
			List(viewModel) { record in
				Section(record.sectionName) {
					ForEach(record.items) { item in
						ItemCell(model: item)
							.swipeActions(edge: .trailing, allowsFullSwipe: true) {
								Button(role: .destructive) {
									Task {
										try await Task.sleep(nanoseconds: 250_000_000)
										try await interactor.removeItem(identifier: item.id)
									}
								} label: {
									Label("Delete", systemImage: "trash")
								}
							}
					}
				}
			}
			.listStyle(.insetGrouped)
			.onReceive(interactor.observeAddedItems()) { output in
				viewModel = output
			}
			.navigationTitle("Items List")
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button {
						path.append(String(describing: ItemPopoverPicker.self))
					} label: {
						Label("Add", systemImage: "plus")
					}
					.navigationDestination(for: String.self) { _ in
						ItemPopoverPicker(path: $path)
					}
				}
			}
		}
	}
}

extension ItemsListView {
	struct Model: Identifiable, Equatable {

		var id: String { items.map(\.id).joined(separator: "_") }
		let sectionName: String
		var items: [ItemCell.Model] = []
	}
}

struct ItemPopoverPicker: View {

	@Binding var path: [String]

	var body: some View {
		List(Item.Kind.allCases) { type in
			NavigationLink {
				Assembly.shared.makeAddItemsView(for: type, path: $path)
			} label: {
				Text(type.presentationValue)
			}
		}
	}
}
