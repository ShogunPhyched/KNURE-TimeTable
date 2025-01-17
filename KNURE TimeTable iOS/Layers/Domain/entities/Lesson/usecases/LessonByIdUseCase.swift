//
//  LessonByIdUseCase.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 12.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

final class LessonByIdUseCase {

	private let repository: LessonRepository

	init(repository: LessonRepository) {
		self.repository = repository
	}
}

extension LessonByIdUseCase: UseCase {
	func execute(_ query: String) async throws -> Lesson {
		try await repository.local(fetch: query)
	}
}
