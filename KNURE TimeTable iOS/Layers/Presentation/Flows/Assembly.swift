//
//  Assembly.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 18.10.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import SwiftUI

@MainActor
final class Assembly {

	static let shared = Assembly()

	private init () {}

	private let persistentStoreContainer = DefaultAppConfig().persistentStoreContainer
	private let urlSessionConfiguration = DefaultAppConfig().urlSessionConfiguration

	func makeItemsView() -> ItemsListView {
		ItemsListView(
			interactor: ItemsListInteractor(
				addedItemsSubscription: AddedItemsSubscription(
					repository: KNUREItemRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					)
				),
				updateTimetableUseCase: UpdateTimetableUseCase(
					lessonRepository: KNURELessonRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						importService: KNURELessonImportService(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					),
					itemRepository: KNUREItemRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					)
				),
				removeItemUseCase: RemoveItemUseCase(
					repository: KNUREItemRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					)
				)
			)
		)
	}

	func makeAddItemsView(for itemType: Item.Kind, path: Binding<[String]>) -> AddItemsListView {
		AddItemsListView(
			path: path,
			interactor: AddItemsInteractor(
				itemsUseCase: ItemsUseCase(
					repository: KNUREItemRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					)
				),
				saveItemUseCase: SaveItemUseCase(
					repository: KNUREItemRepository(
						coreDataService: CoreDataServiceImpl(
							persistentContainer: persistentStoreContainer
						),
						networkService: NetworkServiceImpl(
							configuration: urlSessionConfiguration
						)
					)
				)
			),
			itemType: itemType
		)
	}
}
