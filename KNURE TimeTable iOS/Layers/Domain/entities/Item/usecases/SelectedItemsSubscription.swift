//
//  SelectedItemsSubscription.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine

final class SelectedItemsSubscription {

	private let repository: ItemRepository

	init(repository: ItemRepository) {
		self.repository = repository
	}
}

extension SelectedItemsSubscription: Subscribing {

	func subscribe(_ query: Void) -> AnyPublisher<[Item], Never> {
		repository.localSelectedItems()
	}
}
