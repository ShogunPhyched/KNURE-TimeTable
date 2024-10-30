//
//  ItemManaged+Convertable.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 04/06/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension ItemManaged: Convertable {
	typealias NewType = Item

	func convert() -> Item? {
		guard
			let timetableType = Item.Kind(rawValue: Int(type)),
			let identifier = identifier,
			let title = title
		else { return nil }

		return Item(
			identifier: identifier,
			shortName: title,
			fullName: fullName,
			type: timetableType,
			selected: selected,
			hint: nil,
			updated: Date(timeIntervalSince1970: lastUpdateTimestamp)
		)
	}
}
