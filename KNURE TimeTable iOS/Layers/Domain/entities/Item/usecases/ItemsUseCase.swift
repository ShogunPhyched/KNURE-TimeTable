//
//  ItemsUseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 07/01/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

final class ItemsUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension ItemsUseCase: UseCase {

	func execute(_ request: Item.Kind) async throws -> [Item] {
		try await repository.remote(items: request)
	}
}
