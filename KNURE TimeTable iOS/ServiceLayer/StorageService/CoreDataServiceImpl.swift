//
//  CoreDataServiceImpl.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 24/03/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData
import Combine

final class CoreDataServiceImpl {

	private let persistentContainer: NSPersistentContainer

	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
		self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
	}
}

extension CoreDataServiceImpl: CoreDataService {

	func fetch<T, R: Sendable>(
		_ request: NSFetchRequest<T>,
		_ convert: @escaping @Sendable (T) -> R?
	) async throws -> [R] where T: NSFetchRequestResult {
		let context = persistentContainer.viewContext
		return try await context.perform {
			return try context.fetch(request).compactMap(convert)
		}
	}

	func delete<T>(_ request: NSFetchRequest<T>) async throws where T: NSManagedObject {
		try await persistentContainer.performBackgroundTask { context in
			try context.fetch(request).forEach { context.delete($0) }
			try context.save()
		}
	}

	func perform(_ closure: @escaping (NSManagedObjectContext) -> Void) async throws {
		try await persistentContainer.performBackgroundTask { context in
			closure(context)
			if context.hasChanges {
				try context.save()
			}
		}
	}

	func observe<T, R>(_ request: NSFetchRequest<T>, sectionNameKeyPath: String?) -> AnyPublisher<[R], Never>
		where T: NSFetchRequestResult & Convertable, R == T.NewType {
			Publishers.CoreData(
				request: request,
				context: persistentContainer.viewContext,
				sectionNameKeyPath: sectionNameKeyPath
			)
			.eraseToAnyPublisher()
	}
}
