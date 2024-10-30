//
//  LessonRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

/// Access to lesson data
protocol LessonRepository: Sendable {

	/// Observe timetable with item identifier
	///
	/// - Parameter identifier: item identifier
	/// - Returns: Observable lesson list
//	func localTimetable(identifier: String) -> Observable<[Lesson]>
	// PublishSubject

	/// Access to single lesson by identifier
	///
	/// - Parameter identifier: lesson identifier
	/// - Returns: Promise with finished operation
//	func localLesson(identifier: String) -> Promise<Lesson>

	/// Export timetable with item identifier to local Calendar
	///
	/// - Parameters:
	///   - identifier: item identifier
	///   - range: range for export
	/// - Returns: Promise with finished operation
//	func localExport(identifier: String, range: Void) -> Promise<Void>

    /// Load and store timetable for item identifier
    ///
    /// - Parameter identifier: item identifier
    /// - Returns: Promise with finished operation
	func remoteLoadTimetable(of type: Item.Kind, identifier: String) async throws
}
