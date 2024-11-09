//
//  AddedItemsUseCase.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 09.11.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

final class AddedItemsUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension AddedItemsUseCase: UseCase {

	func execute(_ request: Void) async throws -> [String] {
		try await repository.localAddedItemsIdentifiers()
	}
}
