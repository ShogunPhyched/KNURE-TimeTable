//
//  Item.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

/// Item is the representation of entity than can contain timetable, such as group, teacher or auditory
struct Item: Sendable, Hashable {

	/// unique value to store item
	let identifier: String

	/// short name to represent entity
	let shortName: String

	/// full name to represent, such as full name of teacher
	let fullName: String?

	/// group, teacher or auditory
	let type: Kind

	/// item selection indicator
	let selected: Bool

	/// Item's hint
	let hint: String?

	/// date wich specify the last time this item schedule was updated
	let updated: Date?
}

extension Item {

	/// Basic item types in list
	enum Kind: Int, CaseIterable, Identifiable {
		var id: Int { self.rawValue }

		case group = 1, teacher, auditory
	}
}

extension Item.Kind {

	var presentationValue: String {
		switch self {
		case .group: return "Группы"
		case .teacher: return "Преподаватели"
		case .auditory: return "Аудитории"
		}
	}
}
