//
//  ApplicationConfig.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 06/07/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData

protocol Configuration {
	var urlSessionConfiguration: URLSessionConfiguration { get }
	var persistentStoreContainer: NSPersistentContainer { get }
}

class DefaultAppConfig: Configuration {

	private lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "DataStorage")
		container.loadPersistentStores {
			if let error = $1 {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate.
				// You should not use this function in a shipping application,
				// although it may be useful during development.

				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("\(#file) \(#function) \(error)")
			}
		}
		return container
	}()

	var urlSessionConfiguration: URLSessionConfiguration {
		return .default
	}

	var persistentStoreContainer: NSPersistentContainer {
		return persistentContainer
	}
}
