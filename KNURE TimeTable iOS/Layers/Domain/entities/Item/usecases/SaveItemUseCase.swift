//
//  SaveItemUseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

final class SaveItemUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension SaveItemUseCase: UseCase {

	func execute(_ query: Item) async throws {
		try await repository.local(add: [query])
	}
}
