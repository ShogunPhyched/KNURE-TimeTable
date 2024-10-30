//
//  KNURELessonImportService.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData

final class KNURELessonImportService {

	private let persistentContainer: NSPersistentContainer

	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
}

extension KNURELessonImportService: ImportService {

	func decode(_ data: Data, info: [String: String]) async throws {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		let response = try decoder.decode(KNURE.Response.Lesson.self, from: data)
		try await persistentContainer.performBackgroundTask { context in

			let request: NSFetchRequest<ItemManaged> = ItemManaged.fetchRequest()
			let predicates = info.compactMap { NSPredicate(format: "\($0.key) = %@", $0.value) }
			request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)

			guard let item = try context.fetch(request).first else { return }
			item.lessons?
				.compactMap { $0 as? LessonManaged }
				.forEach { context.delete($0) }

			let subjects = response.subjects.map { $0.toManagedObject(in: context) }
			let types = response.types.map { $0.toManagedObject(in: context) }
			let groups = response.groups.map { $0.toManagedObject(in: context) }
			let teachers = response.teachers.map { $0.toManagedObject(in: context) }

			let lessons = response.events
				.compactMap { event -> Lesson? in
					guard let subject = response.subjects.first(where: { $0.id == event.subjectId }) else { return nil }
					guard let type = response.types.first(where: { $0.id == event.type }) else { return nil }
					return Lesson(event: event, subject: subject, type: type)
				}
				.map { event -> LessonManaged in
					let lesson = event.event.toManagedObject(in: context)
					lesson.subject = subjects.first { $0.identifier == "\(event.subject.id)" }
					lesson.type = types.first { $0.identifier == event.type.id }
					lesson.setValue(NSSet(array: groups), forKey: "groups")
					lesson.setValue(NSSet(array: teachers), forKey: "teachers")
					return lesson
				}

			item.setValue(NSSet(array: lessons), forKey: "lessons")
			item.lastUpdateTimestamp = Date().timeIntervalSince1970

			try context.save()
		}
	}
}

private extension KNURELessonImportService {
	struct Lesson {
		let event: KNURE.Response.Lesson.Event
		let subject: KNURE.Response.Lesson.Subject
		let type: KNURE.Response.Lesson.`Type`
	}
}

private extension KNURE.Response.University.Faculty.Direction.Group {
	func toManagedObject(in context: NSManagedObjectContext) -> GroupManaged {
		let object = GroupManaged(context: context)
		object.identifier = "\(id)"
		object.name = name
		return object
	}
}

private extension KNURE.Response.University.Faculty.Department.Teacher {
	func toManagedObject(in context: NSManagedObjectContext) -> TeacherManaged {
		let object = TeacherManaged(context: context)
		object.identifier = "\(id)"
		object.shortName = shortName
		object.fullName = fullName
		return object
	}
}

private extension KNURE.Response.Lesson.Event {
	func toManagedObject(in context: NSManagedObjectContext) -> LessonManaged {
		let object = LessonManaged(context: context)
		object.numberPair = Int64(numberPair)
		object.auditory = auditory
		object.startTimestamp = startTime
		object.endTimestamp = endTime
		return object
	}
}

private extension KNURE.Response.Lesson.Subject {
	func toManagedObject(in context: NSManagedObjectContext) -> SubjectManaged {
		let object = SubjectManaged(context: context)
		object.identifier = "\(id)"
		object.brief = brief
		object.title = title
		return object
	}
}

private extension KNURE.Response.Lesson.`Type` {
	func toManagedObject(in context: NSManagedObjectContext) -> TypeManaged {
		let object = TypeManaged(context: context)
		object.identifier = Int64(id)
		object.baseId = Int64(idBase)
		object.shortName = shortName
		object.fullName = fullName
		return object
	}
}
