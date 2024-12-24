//
//  TimetableSubscription.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine
import Foundation

final class TimetableSubscription {

	private let repository: LessonRepository

	static let calendar: Calendar = {
		var calendar = Calendar.current
		calendar.timeZone = .current
		return calendar
	}()

	init(repository: LessonRepository) {
		self.repository = repository
	}
}

extension TimetableSubscription: Subscribing {

	func subscribe(_ request: String) -> AnyPublisher<[[Lesson]], Never> {
		repository.localTimetable(identifier: request)
			.map { $0.grouped(by: \.day) }
			.eraseToAnyPublisher()
			.appendingDummyDays()
	}
}

private extension AnyPublisher where Output == [[Lesson]], Failure == Never {

	func appendingDummyDays() -> AnyPublisher<[[Lesson]], Never> {
		self.map {
			var lessons = $0
			let result = lessons.appendingEmptyLessons()
			return result
		}
			.eraseToAnyPublisher()
	}
}

private extension Array where Element == [Lesson] {

	mutating func appendingEmptyLessons() -> [[Lesson]] {
		guard !isEmpty else { return self }

		let range = self.flatMap({ $0 }).minMaxRange

		for index in 0..<self.count {
			for subindex in range where !self[index].contains(where: { $0.number == subindex }) {
				let dummy = Lesson(
					auditory: "",
					start: self[index].first!.start,
					end: self[index].first!.end,
					number: subindex,
					subject: .init(identifier: "", brief: "", title: ""),
					type: .init(identifier: 1337, baseIdentifier: 1337, fullName: "", shortName: ""),
					groups: [],
					teachers: [],
					dummy: true
				)

				self[index].append(dummy)
			}
			self[index].sort { $0.number < $1.number }
		}

		return self
	}
}
