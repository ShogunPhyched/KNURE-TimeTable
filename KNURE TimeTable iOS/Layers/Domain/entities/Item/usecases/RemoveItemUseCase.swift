//
//  RemoveItemUseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

final class RemoveItemUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension RemoveItemUseCase: UseCase {

	func execute(_ query: String) async throws {
		try await repository.local(delete: query)
	}
}
