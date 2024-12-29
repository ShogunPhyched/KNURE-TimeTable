//
//  KNURELessonRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData
import Combine

final class KNURELessonRepository {

	private let coreDataService: CoreDataService
	private let importService: ImportService
	private let networkService: NetworkService

	init(
		coreDataService: CoreDataService,
		importService: ImportService,
		networkService: NetworkService
	) {
		self.coreDataService = coreDataService
		self.importService = importService
		self.networkService = networkService
	}
}

extension KNURELessonRepository: LessonRepository {

	func localTimetable(identifier: String) -> AnyPublisher<[Lesson], Never> {
		let request = LessonManaged.fetchRequest()
		request.predicate = NSPredicate(format: "item.identifier = %@", identifier)
		request.sortDescriptors = [
			NSSortDescriptor(key: "startTimestamp", ascending: true),
			NSSortDescriptor(key: "subject.brief", ascending: true)
		]
		return coreDataService.observe(request)
			.eraseToAnyPublisher()
	}

	func local(fetch identifier: String) async throws -> Lesson {
		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
		request.predicate = NSPredicate(format: "item.identifier = %@", identifier)
		guard let lesson = try await coreDataService.fetch(request, { $0.convert() }).first else {
			throw Error.lessonNotFound
		}

		return lesson
	}

	func remoteLoadTimetable(of type: Item.Kind, identifier: String) async throws {
		let request = try KNURE.Request.make(endpoint: .timetable(type, identifier))
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let data = try await networkService.execute(request).data.transform(from: .windowsCP1251, to: .utf8)
		try await importService.decode(data, info: ["identifier": identifier])
	}

	enum Error: Swift.Error {
		case lessonNotFound
	}
}
