//
//  MigrationService.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 01.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

import CoreData

final class MigrationService: Sendable {

	init(persistentContainer: NSPersistentContainer) {
		do {
			let coordinator = NSPersistentStoreCoordinator(
				managedObjectModel: persistentContainer.managedObjectModel
			)

			// Set the options to enable lightweight data migrations.
			let options = [
				NSMigratePersistentStoresAutomaticallyOption: true,
				NSInferMappingModelAutomaticallyOption: true
			]

			// Set the options when you add the store to the coordinator.
			_ = try coordinator.addPersistentStore(
				type: .sqlite,
				at: URL(fileURLWithPath: ""),
				options: options
			)

		} catch {
			print("Error migrating CoreData: \(error)")
		}
	}
}
