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

	private lazy var coreDataService: CoreDataService = CoreDataServiceImpl(
		persistentContainer: persistentStoreContainer
	)

	private lazy var networkService: NetworkService = NetworkServiceImpl(
		configuration: urlSessionConfiguration
	)

	private lazy var lessonRepository: KNURELessonRepository = KNURELessonRepository(
		coreDataService: coreDataService,
		importService: KNURELessonImportService(persistentContainer: persistentStoreContainer),
		networkService: networkService
	)

	private lazy var itemRepository: KNUREItemRepository = KNUREItemRepository(
		coreDataService: coreDataService,
		networkService: networkService
	)

	func makeTimetableView() -> TimetableViewController {
		TimetableViewController(
			interactor: TimetableInteractor(
				addedItemsSubscription: AddedItemsSubscription(repository: itemRepository),
				timetableSubscription: TimetableSubscription(repository: lessonRepository),
				updateTimetableUseCase: UpdateTimetableUseCase(lessonRepository: lessonRepository),
				selectItemUseCase: SelectItemUseCase(repository: itemRepository)
			)
		)
	}

	func makeItemsView() -> ItemsListView {
		ItemsListView(
			interactor: ItemsListInteractor(
				addedItemsSubscription: AddedItemsSubscription(repository: itemRepository),
				updateTimetableUseCase: UpdateTimetableUseCase(lessonRepository: lessonRepository),
				removeItemUseCase: RemoveItemUseCase(repository: itemRepository),
				selectItemUseCase: SelectItemUseCase(repository: itemRepository)
			)
		)
	}

	func makeAddItemsView(for itemType: Item.Kind, path: Binding<[String]>) -> AddItemsListView {
		AddItemsListView(
			path: path,
			interactor: AddItemsInteractor(
				itemsUseCase: ItemsUseCase(repository: itemRepository),
				saveItemUseCase: SaveItemUseCase(repository: itemRepository),
				addedItemsUseCase: AddedItemsUseCase(repository: itemRepository)
			),
			itemType: itemType
		)
	}
}
