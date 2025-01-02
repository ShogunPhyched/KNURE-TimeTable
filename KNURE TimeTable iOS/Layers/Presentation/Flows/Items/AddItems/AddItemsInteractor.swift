//
//  AddItemsInteractor.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 13.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

protocol AddItemsInteractorInput: Sendable {
	func obtainItems(kind: Item.Kind) async throws -> [AddItemsListView.Section]
	func save(item: Item) async throws
}

final class AddItemsInteractor {

	private let itemsUseCase: any UseCase<Item.Kind, [KNURE.Response.Section]>
	private let saveItemUseCase: any UseCase<Item, Void>
	private let addedItemsUseCase: any UseCase<Void, [String]>

	init(
		itemsUseCase: any UseCase<Item.Kind, [KNURE.Response.Section]>,
		saveItemUseCase: any UseCase<Item, Void>,
		addedItemsUseCase: any UseCase<Void, [String]>
	) {
		self.itemsUseCase = itemsUseCase
		self.saveItemUseCase = saveItemUseCase
		self.addedItemsUseCase = addedItemsUseCase
	}
}

extension AddItemsInteractor: AddItemsInteractorInput {
	func obtainItems(kind: Item.Kind) async throws -> [AddItemsListView.Section] {
		let addedItemsIdentifiers = try await addedItemsUseCase.execute(())
		return try await itemsUseCase.execute(kind).map { section in
			AddItemsListView.Section(
				title: section.name,
				models: section.items.map { item in
					AddItemsListView.Model(
						title: item.shortName,
						selected: addedItemsIdentifiers.contains(item.identifier),
						item: item
					)
				}
			)
		}
	}

	func save(item: Item) async throws {
		try await saveItemUseCase.execute(item)
	}
}
