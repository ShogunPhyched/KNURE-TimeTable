//
//  ItemsListInteractor.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 01.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Combine

@MainActor
protocol ItemsListInteractorInput {

	func observeAddedItems() -> AnyPublisher<[ItemsListView.Model], Never>

	func updateTimetable(of type: Item.Kind, identifier: String) async throws

	func removeItem(identifier: String) async throws
}

@MainActor
final class ItemsListInteractor {

	private let addedItemsSubscription: any Subscribing<Void, [Item.Kind: [Item]]>
	private let updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>
	private let removeItemUseCase: any UseCase<RemoveItemUseCase.Request, Void>

	init(
		addedItemsSubscription: any Subscribing<Void, [Item.Kind: [Item]]>,
		updateTimetableUseCase: any UseCase<UpdateTimetableUseCase.Query, Void>,
		removeItemUseCase: any UseCase<RemoveItemUseCase.Request, Void>
	) {
		self.addedItemsSubscription = addedItemsSubscription
		self.updateTimetableUseCase = updateTimetableUseCase
		self.removeItemUseCase = removeItemUseCase
	}
}

extension ItemsListInteractor: ItemsListInteractorInput {

	func observeAddedItems() -> AnyPublisher<[ItemsListView.Model], Never> {
		addedItemsSubscription.subscribe(())
			.map { dictionary in
				dictionary.map { key, value in
					ItemsListView.Model(
						sectionName: key.presentationValue,
						items: value.map {
							ItemCell.Model(
								id: $0.identifier,
								title: $0.shortName,
								subtitle: String(describing: $0.updated),
								state: .idle
							)
						}
					)
				}
			}
			.eraseToAnyPublisher()
	}

	func updateTimetable(of type: Item.Kind, identifier: String) async throws {
		try await updateTimetableUseCase.execute(.init(identifier: identifier, type: type))
	}

	func removeItem(identifier: String) async throws {
		try await removeItemUseCase.execute(identifier)
	}
}
