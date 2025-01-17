//
//  ItemsListInteractor.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 01.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Combine

protocol ItemsListInteractorInput: Sendable {

	func observeAddedItems() -> AnyPublisher<[ItemsListView.Model], Never>

	func updateTimetable(of type: Item.Kind, identifier: String) async throws

	func removeItem(identifier: String) async throws
}

final class ItemsListInteractor {

	private let addedItemsSubscription: any Subscribing<Void, [Item]>
	private let updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>
	private let removeItemUseCase: any UseCase<RemoveItemUseCase.Request, Void>
	private let selectItemUseCase: any UseCase<String, Void>

	init(
		addedItemsSubscription: any Subscribing<Void, [Item]>,
		updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>,
		removeItemUseCase: any UseCase<RemoveItemUseCase.Request, Void>,
		selectItemUseCase: any UseCase<String, Void>
	) {
		self.addedItemsSubscription = addedItemsSubscription
		self.updateTimetableUseCase = updateTimetableUseCase
		self.removeItemUseCase = removeItemUseCase
		self.selectItemUseCase = selectItemUseCase
	}
}

extension ItemsListInteractor: ItemsListInteractorInput {

	func observeAddedItems() -> AnyPublisher<[ItemsListView.Model], Never> {
		addedItemsSubscription.subscribe(())
			.map { Dictionary(grouping: $0, by: \.type) }
			.map { dictionary in
				dictionary.map { key, value in
					ItemsListView.Model(
						sectionName: key.presentationValue,
						items: value.map {
							ItemCell.Model(
								id: $0.identifier,
								title: $0.shortName,
								subtitle: self.subtile(for: $0),
								state: .idle,
								type: $0.type
							)
						}
					)
				}
			}
			.eraseToAnyPublisher()
	}

	func updateTimetable(of type: Item.Kind, identifier: String) async throws {
		try await updateTimetableUseCase.execute(.init(identifier: identifier, type: type))
		try await selectItemUseCase.execute(identifier)
	}

	func removeItem(identifier: String) async throws {
		try await removeItemUseCase.execute(identifier)
	}
}

private extension ItemsListInteractor {
	func subtile(for item: Item) -> String {
		if let updated = item.updated {
			return "Updated: " + updated.formatted(date: .abbreviated, time: .standard)
		}
		return "Not updated"
	}
}
