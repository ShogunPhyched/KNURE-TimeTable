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

	func localTimetable(identifier: String) -> AnyPublisher<[[Lesson]], Never> {
		let request = NSFetchRequest<LessonManaged>(entityName: "LessonManaged")
		request.predicate = NSPredicate(format: "item.identifier = %@", identifier)
		request.sortDescriptors = [NSSortDescriptor(key: "startTimestamp", ascending: true)]
		return coreDataService.observe(request)
			.map { $0.grouped(by: \.day) }
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
//		let response = try await networkService.execute(request)
//		let data = try networkService.validate(response).transform(from: .windowsCP1251, to: .utf8)

		let data = MockJSONLoader.load(json: "timetable", item: .groups)

		try await importService.decode(data, info: ["identifier": identifier])
	}

	enum Error: Swift.Error {
		case lessonNotFound
	}
}

private extension Sequence {
	func grouped<T: Equatable>(by block: (Element) throws -> T) rethrows -> [[Element]] {
		return try reduce(into: []) { result, element in
			if let lastElement = result.last?.last, try block(lastElement) == block(element) {
				result[result.index(before: result.endIndex)].append(element)
			} else {
				result.append([element])
			}
		}
	}
}
