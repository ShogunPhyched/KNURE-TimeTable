//
//  Lesson.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

struct Lesson: Sendable, Equatable {

	let auditory: String

	let start: Date

	let end: Date

	let number: Int

	let subject: Subject

	let type: Kind

	let groups: [Group]

	let teachers: [Teacher]
}

extension Lesson {

	struct Subject: Sendable, Equatable {

		let identifier: String?

		let brief: String?

		let title: String?
	}

	struct Kind: Sendable, Equatable {

		let identifier: Int64

		let baseIdentifier: Int64

		let fullName: String?

		let shortName: String?
	}

	struct Group: Sendable, Equatable {

		let identifier: String
		
		let name: String
	}

	struct Teacher: Sendable, Equatable {

		let identifier: String
		
		let shortName: String

		let fullName: String
	}
}
