//
//  AddItemCell.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 27.02.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct AddItemCell: View {

	var model: Model

    var body: some View {
		HStack(alignment: .center) {
			VStack(alignment: .leading) {
				if model.selected {
					Text(model.title)
						.fontWeight(.bold)
				} else {
					Text(model.title)
				}

			}
			Spacer()
			if model.selected {
				Image(systemName: "checkmark")
					.foregroundStyle(.blue)
			}
		}
    }

	struct Model: Identifiable {

		let id: UUID = .init()

		let title: String
		var selected: Bool
	}
}

#Preview {
	AddItemCell(model: .init(title: "Some Name", selected: true))
}
