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
						.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
				} else {
					Text(model.title)
						.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
				}

			}
			Spacer()
			if model.selected {
				Image(systemName: "checkmark")
					.foregroundStyle(.blue)
					.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
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
