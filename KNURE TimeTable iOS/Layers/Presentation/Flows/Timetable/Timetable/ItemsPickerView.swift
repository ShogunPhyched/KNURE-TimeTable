//
//  ItemsPickerView.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 29.12.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

struct ItemsPickerView: View {

	@State var items: [Item]
	let onSelect: ((Item) -> Void)

	@Environment(\.dismiss) var dismiss

	var body: some View {
		List {
			ForEach(items) { item in
				HStack {
					Button(action: {
						for index in items.indices {
							items[index].selected = items[index] == item
						}
						onSelect(item)
						dismiss()
					}, label: {
						Text(item.shortName)
					})
					.tint(.primary)
					if item.selected {
						Spacer()
						Image(systemName: "checkmark")
					}
				}
			}
		}
	}
}
