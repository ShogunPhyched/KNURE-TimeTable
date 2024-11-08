//
//  LessonManaged+Domain.swift
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
			let auditory, let subject, let type
		else { return nil }
		return Lesson(
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
			groups: [],
			teachers: []
		)
	}
}
