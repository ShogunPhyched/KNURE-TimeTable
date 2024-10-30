//
//  ItemCell.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 26.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct ItemCell: View {

	var model: Model

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
					Button(role: nil) {

					} label: {
						Image(systemName: "arrow.down.to.line")
							.foregroundStyle(.blue)
					}
				case .selected:
					Button(role: nil) {

					} label: {
						Image(systemName: "checkmark")
							.foregroundStyle(.blue)
					}
				case .updating:
					ProgressView()
			}
		}
    }

	struct Model: Identifiable, Equatable {

		let id: String

		let title: String
		let subtitle: String
		let state: State

		enum State: String {
			case idle
			case selected
			case updating
		}
	}
}

#Preview {
	ItemCell(model: .init(id: "some", title: "PI-11-3", subtitle: "Not updated", state: .idle))
}
