//
//  LessonManaged+Convertable.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08/08/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension LessonManaged: Convertable {
	typealias NewType = Lesson

	func convert() -> Lesson? {
		guard
			let auditory,
			let subject,
			let type,
			let identifier,
			let timeZone = TimeZone(identifier: timeZone ?? "Europe/Kiev")
		else { return nil }

		let groups = groups as? Set<GroupManaged> ?? []
		let teachers = teachers as? Set<TeacherManaged> ?? []

		return Lesson(
			identifier: identifier,
			timeZone: timeZone,
			auditory: auditory,
			start: Date(timeIntervalSince1970: startTimestamp),
			end: Date(timeIntervalSince1970: endTimestamp),
			number: Int(numberPair),
			subject: Lesson.Subject(
				identifier: subject.identifier,
				brief: subject.brief,
				title: subject.title
			),
			type: Lesson.Kind(
				identifier: type.identifier,
				baseIdentifier: type.baseId,
				fullName: type.fullName,
				shortName: type.shortName
			),
			groups: groups
				.compactMap {
					guard let identifier = $0.identifier, let name = $0.name else { return nil }
					return Lesson.Group(identifier: identifier, name: name)
				}
				.sorted { $0.name < $1.name },
			teachers: teachers
				.compactMap {
					guard let identifier = $0.identifier, let shortName = $0.shortName, let fullName = $0.fullName else {
						return nil
					}
					return Lesson.Teacher(identifier: identifier, shortName: shortName, fullName: fullName)
				}
				.sorted { $0.shortName < $1.shortName },
			dummy: false
		)
	}
}
