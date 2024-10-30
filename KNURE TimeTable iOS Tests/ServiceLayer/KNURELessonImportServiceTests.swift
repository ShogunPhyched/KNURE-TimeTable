//
//  KNURELessonImportServiceTests.swift
//  KNURE TimeTable iOS Tests
//
//  Created by Vladislav Chapaev on 23/02/2021.
//  Copyright © 2021 Vladislav Chapaev. All rights reserved.
//

import XCTest
import CoreData
@testable import KNURE_TimeTable_iOS

final class KNURELessonImportServiceTests: XCTestCase {

	var sut: KNURELessonImportService!
	var storeWrapper: PersistentContainerWrapper!

    override func setUp() {
		super.setUp()
		storeWrapper = PersistentContainerWrapper()
		sut = KNURELessonImportService(persistentContainer: storeWrapper.persistentContainer)
	}

    override func tearDown() {
		sut = nil
		storeWrapper = nil
		super.tearDown()
    }

	func testSuccessLessonImport() async throws {
		// arrange
		let context = storeWrapper.persistentContainer.newBackgroundContext()
		let itemManaged = ItemManaged(context: context)
		itemManaged.identifier = "6949706"
		try context.save()

		let data = MockJSONLoader.load(json: "timetable", item: .groups)

		// act
		try await sut.decode(data, info: ["identifier": "6949706"])

		// assert
		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
		let result = XCTAssertNoRethrow(try storeWrapper.persistentContainer.viewContext.fetch(request))
		XCTAssertGreaterThan(result.count, 0)
	}

	func testEmptyItemsResultShouldNotImportLessons() async throws {
	    // arrange
		let data = MockJSONLoader.load(json: "timetable", item: .groups)

		// act
		try await sut.decode(data, info: ["identifier": "6949706"])

		// assert
		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
		let result = try storeWrapper.persistentContainer.viewContext.fetch(request)
		XCTAssertEqual(result.count, 0)
	}
}

struct PersistentContainerWrapper {
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "DataStorage")

		let description = container.persistentStoreDescriptions.first
		description?.url = URL(fileURLWithPath: "/dev/null")

		container.loadPersistentStores(completionHandler: { _, error in
			if let error = error as NSError? {
				fatalError("Failed to load stores: \(error), \(error.userInfo)")
			}
		})

		return container
	}()
}
