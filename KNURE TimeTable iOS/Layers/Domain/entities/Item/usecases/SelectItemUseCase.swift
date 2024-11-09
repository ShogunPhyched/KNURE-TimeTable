//
//  SelectItemUseCase.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 09.11.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

final class SelectItemUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension SelectItemUseCase: UseCase {

	func execute(_ request: String) async throws {
		try await repository.local(select: request)
	}
}
