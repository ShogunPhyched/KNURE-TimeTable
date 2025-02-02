//
//  ItemCell.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 26.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct ItemCell: View {

	@State var model: Model

	let interactor: ItemsListInteractorInput

    var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				Text(model.title)
					.fontWeight(.medium)
					.font(.title3)
				Text(model.subtitle)
					.foregroundStyle(.gray)
			}
			Spacer()
			switch model.state {
				case .idle:
					Image(systemName: "arrow.down.to.line")
						.foregroundStyle(.blue)

				case .selected:
					Image(systemName: "checkmark")
						.foregroundStyle(.blue)

				case .updating:
					ProgressView()
			}
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button(role: .destructive) {
				Task {
					try await Task.sleep(nanoseconds: 250_000_000)
					try await interactor.removeItem(identifier: model.id)
				}
			} label: {
				Label("Delete", systemImage: "trash")
			}
		}
    }

	struct Model: Identifiable, Equatable {

		let id: String

		let title: String
		let subtitle: String
		var state: State
		let type: Item.Kind

		enum State: String {
			case idle
			case selected
			case updating
		}
	}
}
