//
//  LessonRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine

/// Access to lesson data
protocol LessonRepository: Sendable {

	/// Observe timetable with item identifier
	///
	/// - Parameter identifier: item identifier
	/// - Returns: Observable lesson list
	func localTimetable(identifier: String) -> AnyPublisher<[Lesson], Never>

	/// Access to single lesson by identifier
	///
	/// - Parameter identifier: lesson identifier
	/// - Returns: Promise with finished operation
	func local(fetch identifier: String) async throws -> Lesson

    /// Load and store timetable for item identifier
    ///
    /// - Parameter identifier: item identifier
    /// - Returns: Promise with finished operation
	func remoteLoadTimetable(of type: Item.Kind, identifier: String) async throws
}
