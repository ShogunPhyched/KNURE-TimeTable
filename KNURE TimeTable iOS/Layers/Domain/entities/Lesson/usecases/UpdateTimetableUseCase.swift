//
//  UpdateTimetableUseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 12/05/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

final class UpdateTimetableUseCase {

	private let lessonRepository: LessonRepository
	private let itemRepository: ItemRepository

	init(
		lessonRepository: LessonRepository,
		itemRepository: ItemRepository
	) {
		self.lessonRepository = lessonRepository
		self.itemRepository = itemRepository
	}
}

extension UpdateTimetableUseCase: UseCase {

	struct Query: Sendable {
		let identifier: String
		let type: Item.Kind
	}

	func execute(_ request: Query) async throws {
		try await lessonRepository.remoteLoadTimetable(of: request.type, identifier: request.identifier)
		try await itemRepository.local(setLastUpdate: Date(), for: request.identifier)
	}
}
