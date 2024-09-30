//
//  AddedItemsUseCase.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.09.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Combine

final class AddedItemsUseCase {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension AddedItemsUseCase: Subscribing {

	func subscribe(_ request: Void) -> AnyPublisher<[Item.Kind: [Item]], Never> {
		repository.localAddedItems()
	}
}
