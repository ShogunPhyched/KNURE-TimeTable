//
//  TimetableInteractor.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine

protocol TimetableInteractorInput {
	func updateTimetable(identifier: String) async throws

	func observeTimetableUpdates(identifier: String) -> AnyPublisher<TimetableCollectionController.TimetableModel, Never>
}

final class TimetableInteractor {

	private let timetableSubscription: any Subscribing<String, [Lesson]>

	init(timetableSubscription: any Subscribing<String, [Lesson]>) {
		self.timetableSubscription = timetableSubscription
	}

}

extension TimetableInteractor: TimetableInteractorInput {
	func updateTimetable(identifier: String) async throws {
//		_ = updateTimetableUseCase.execute(identifier)
	}

	func observeTimetableUpdates(identifier: String) -> AnyPublisher<TimetableCollectionController.TimetableModel, Never> {
		timetableSubscription
			.subscribe(identifier)
			.map { lessons in
				lessons.map { lesson in
					LessonCollectionViewCellModel(
						subjectId: lesson.subject.identifier ?? "",
						baseIdentifier: lesson.type.baseIdentifier,
						title: lesson.subject.brief ?? "",
						subtitle: lesson.auditory,
						startTime: lesson.start,
						endTime: lesson.end
					)
				}
			}
			.map(TimetableCollectionController.TimetableModel.init(cellModels:))
			.eraseToAnyPublisher()
	}
}
