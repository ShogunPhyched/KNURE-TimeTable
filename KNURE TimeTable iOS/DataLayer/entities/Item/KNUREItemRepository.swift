//
//  KNUREItemRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData
import Combine

final class KNUREItemRepository {

	private let coreDataService: CoreDataService
	private let networkService: NetworkService

	init(
		coreDataService: CoreDataService,
		networkService: NetworkService
	) {
		self.coreDataService = coreDataService
		self.networkService = networkService
	}
}

extension KNUREItemRepository: ItemRepository {

	func localSelectedItems() -> AnyPublisher<[Item], Never> {
		let request = NSFetchRequest<ItemManaged>(entityName: "ItemManaged")
		request.predicate = NSPredicate(format: "selected = %@", NSNumber(value: true))
		request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		return coreDataService.observe(request, sectionNameKeyPath: nil)
	}

	func localAddedItems() -> AnyPublisher<[Item.Kind: [Item]], Never> {
		let request = NSFetchRequest<ItemManaged>(entityName: "ItemManaged")
		request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		return coreDataService.observe(request, sectionNameKeyPath: "type")
			.map { [Item.Kind(rawValue: $0): $0.values] }
			.eraseToAnyPublisher()
	}

	func local(add items: [Item]) async throws {
		try await coreDataService.perform { context in
			for item in items {
				let managedObject = ItemManaged(context: context)
				managedObject.identifier = item.identifier
				managedObject.type = Int64(item.type.rawValue)
				managedObject.title = item.shortName
				managedObject.fullName = item.fullName
			}
		}
	}

	func local(delete identifier: String) async throws {
		let request = NSFetchRequest<ItemManaged>(entityName: "ItemManaged")
		request.predicate = NSPredicate(format: "identifier = %@", identifier)
		try await coreDataService.delete(request)
	}

	func remote(items type: Item.Kind) async throws -> [Item]{
		let request = try KNURE.Request.make(endpoint: .item(type))

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let response = try await networkService.execute(request)
		let data = try handle(response).transform(from: .windowsCP1251, to: .utf8)
		let decoded = try decoder.decode(KNURE.Response.self, from: data)
		return transform(response: decoded, by: type)
	}
}

private extension KNUREItemRepository {
	func handle(_ response: NetworkResponse) throws -> Data {
		guard response.status == .ok else { throw response.status }
		return response.data
	}

	func transform(response: KNURE.Response, by type: Item.Kind) -> [Item] {
		switch type {
		case .group:
			return response.university.groups
		case .teacher:
			return response.university.teachers
		case .auditory:
			return response.university.auditories
		}
	}
}
