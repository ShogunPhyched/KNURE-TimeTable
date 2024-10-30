//
//  AddItemsInteractor.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 13.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

protocol AddItemsInteractorInput: Sendable {
	func obtainItems(kind: Item.Kind) async throws -> [AddItemsListView.Model]
	func save(item: Item) async throws
}

final class AddItemsInteractor {

	private let itemsUseCase: any UseCase<Item.Kind, [Item]>
	private let saveItemUseCase: any UseCase<Item, Void>

	init(
		itemsUseCase: any UseCase<Item.Kind, [Item]>,
		saveItemUseCase: any UseCase<Item, Void>
	) {
		self.itemsUseCase = itemsUseCase
		self.saveItemUseCase = saveItemUseCase
	}
}

extension AddItemsInteractor: AddItemsInteractorInput {
	func obtainItems(kind: Item.Kind) async throws -> [AddItemsListView.Model] {
		try await itemsUseCase.execute(kind).map {
			AddItemsListView.Model(title: $0.shortName, selected: $0.selected, item: $0)
		}
	}

	func save(item: Item) async throws {
		try await saveItemUseCase.execute(item)
	}
}
