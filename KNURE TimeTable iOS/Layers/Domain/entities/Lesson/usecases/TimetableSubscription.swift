//
//  TimetableSubscription.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine

final class TimetableSubscription {

	private let repository: LessonRepository

	init(repository: LessonRepository) {
		self.repository = repository
	}
}

extension TimetableSubscription: Subscribing {

	func subscribe(_ request: String) -> AnyPublisher<[Lesson], Never> {
		repository.localTimetable(identifier: request)
	}
}
