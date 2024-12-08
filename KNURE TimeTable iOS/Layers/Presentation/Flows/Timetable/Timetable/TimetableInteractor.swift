//
//  TimetableInteractor.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine

protocol TimetableInteractorInput {

	func observeAddedItems() -> AnyPublisher<[Item], Never>

	func updateTimetable(identifier: String, type: Item.Kind) async throws

	func selectItem(identifier: String) async throws

	func observeTimetableUpdates(
		identifier: String
	) -> AnyPublisher<TimetableModel, Never>
}

final class TimetableInteractor {

	private let addedItemsSubscription: any Subscribing<Void, [Item]>
	private let timetableSubscription: any Subscribing<String, [[Lesson]]>
	private let updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>
	private let selectItemUseCase: any UseCase<String, Void>

	init(
		addedItemsSubscription: any Subscribing<Void, [Item]>,
		timetableSubscription: any Subscribing<String, [[Lesson]]>,
		updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>,
		selectItemUseCase: any UseCase<String, Void>
	) {
		self.addedItemsSubscription = addedItemsSubscription
		self.timetableSubscription = timetableSubscription
		self.updateTimetableUseCase = updateTimetableUseCase
		self.selectItemUseCase = selectItemUseCase
	}
}

extension TimetableInteractor: TimetableInteractorInput {

	func observeAddedItems() -> AnyPublisher<[Item], Never> {
		addedItemsSubscription.subscribe(())
			.eraseToAnyPublisher()
	}

	func updateTimetable(identifier: String, type: Item.Kind) async throws {
		try await updateTimetableUseCase.execute(.init(identifier: identifier, type: type))
	}

	func selectItem(identifier: String) async throws {
		try await selectItemUseCase.execute(identifier)
	}

	func observeTimetableUpdates(
		identifier: String
	) -> AnyPublisher<TimetableModel, Never> {
		timetableSubscription
			.subscribe(identifier)
			.map { timetable in
				let sections = timetable.map { lessons in
					let groups = lessons.grouped(by: \.number).map { lessons in
						let cellModels = lessons.map { lesson in
							LessonCollectionViewCellModel(
								subjectId: lesson.subject.identifier ?? "",
								baseIdentifier: lesson.type.baseIdentifier,
								title: lesson.subject.brief ?? "",
								subtitle: lesson.auditory,
								startTime: lesson.start,
								endTime: lesson.end,
								number: lesson.number
							)
						}

						return TimetableModel.Section.Group(cellModels: cellModels)
					}

					return TimetableModel.Section(groups: groups)
				}

				return TimetableModel(sections: sections)
			}
			.eraseToAnyPublisher()
	}
}
