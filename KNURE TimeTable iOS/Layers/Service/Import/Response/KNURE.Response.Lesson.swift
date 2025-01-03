//
//  KNURE.Response.Lesson.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 15/11/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension KNURE.Response {
	struct Lesson: Decodable {
		@Omissible var events: [Event]
		@Omissible var subjects: [Subject]
		@Omissible var groups: [University.Faculty.Direction.Group]
		@Omissible var teachers: [University.Faculty.Department.Teacher]
		@Omissible var types: [Type]
	}
}

extension KNURE.Response.Lesson {
	struct Event: Decodable {
		let subjectId: Int
		let startTime: TimeInterval
		let endTime: TimeInterval
		let type: Int
		let numberPair: Int
		let auditory: String
		@Omissible var teachers: [Int]
		@Omissible var groups: [Int]
	}

	struct Subject: Decodable {
		let id: Int
		let brief: String
		let title: String
		@Omissible var hours: [Hour]
	}

	struct `Type`: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
		let idBase: Int
		let type: String
	}
}

extension KNURE.Response.Lesson.Subject {
	struct Hour: Decodable {
		let type: Int
		let val: Int
		@Omissible var teachers: [Int]
	}
}
