//
//  UpdateTimetableUseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 12/05/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

final class UpdateTimetableUseCase {

	private let repository: LessonRepository

	init(repository: LessonRepository) {
		self.repository = repository
	}
}

extension UpdateTimetableUseCase: UseCase {

	struct Query: Sendable {
		let identifier: String
		let type: Item.Kind
	}

	func execute(_ request: Query) async throws {
		try await repository.remoteLoadTimetable(of: request.type, identifier: request.identifier)
	}
}
