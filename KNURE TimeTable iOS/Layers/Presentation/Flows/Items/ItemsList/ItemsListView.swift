//
//  ItemsListView.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 26.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI
import Combine

struct ItemsListView: View {

	@State private var path: [String] = []

	@State private var viewModel: [ItemsListView.Model] = []
	@State private var isErrorOccured: Bool = false
	@State private var error: Error?
	@State private var cancellables: Set<AnyCancellable> = []

	let interactor: ItemsListInteractorInput

	var body: some View {
		NavigationStack(path: $path) {
			List(viewModel) { record in
				Section(header: Text(record.sectionName)) {
					ForEach(record.items) { item in
						ItemCell(model: item, interactor: interactor)
							.onTapGesture {
								Task {
									updateItemState(identifier: item.id, state: .updating)
									do {
										try await interactor.updateTimetable(of: item.type, identifier: item.id)
									} catch {
										isErrorOccured = true
										self.error = error
									}
								}
							}
					}
				}
			}
			.onAppear {
				interactor.observeAddedItems()
					.sink { viewModel = $0 }
					.store(in: &cancellables)
			}
			.navigationTitle("Items List")
			.alert("An Error has occured", isPresented: $isErrorOccured, actions: {
				Button(role: .cancel) {
					isErrorOccured = false
				} label: {
					Text("Ok")
				}
			}, message: {
				Text(error?.localizedDescription ?? "")
			})
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

		var id: String { items.map(\.id).joined(separator: "_") + items.map(\.state.rawValue).joined(separator: "_") }
		let sectionName: String
		var items: [ItemCell.Model] = []
	}

	func updateItemState(identifier: String, state: ItemCell.Model.State) {
		for index in viewModel.indices {
			for subindex in viewModel[index].items.indices where viewModel[index].items[subindex].id == identifier {
				viewModel[index].items[subindex].state = state
			}
		}
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
