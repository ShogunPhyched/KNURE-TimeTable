//
//  Lesson.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

struct Lesson: Sendable {

//	let auditory: String
//
//	let start: Date
//
//	let end: Date
//
//	let number: Int
//
//	let subject: Subject
}

extension Lesson {

	struct Subject: Sendable {

		let identifier: String

		let brief: String

		let title: String
	}
}
