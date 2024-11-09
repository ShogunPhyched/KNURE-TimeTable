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

	init(
		lessonRepository: LessonRepository
	) {
		self.lessonRepository = lessonRepository
	}
}

extension UpdateTimetableUseCase: UseCase {

	struct Query: Sendable {
		let identifier: String
		let type: Item.Kind
	}

	func execute(_ request: Query) async throws {
		try await lessonRepository.remoteLoadTimetable(of: request.type, identifier: request.identifier)
	}
}
