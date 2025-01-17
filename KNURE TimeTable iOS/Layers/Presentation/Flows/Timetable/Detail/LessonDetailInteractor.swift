//
//  LessonDetailInteractor.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 10.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

protocol LessonDetailInteractorInput: Sendable {

	func obtainContent(_ identifier: String) async -> (String, [LessonDetailView.ViewModel])
}

final class LessonDetailInteractor {

	private let lessonDetailUseCase: any UseCase<String, Lesson>

	init(lessonDetailUseCase: any UseCase<String, Lesson>) {
		self.lessonDetailUseCase = lessonDetailUseCase
	}
}

extension LessonDetailInteractor: LessonDetailInteractorInput {

	func obtainContent(_ identifier: String) async -> (String, [LessonDetailView.ViewModel]) {
		do {
			let lesson = try await lessonDetailUseCase.execute(identifier)

			var viewModels: [LessonDetailView.ViewModel] = []

			viewModels.append(
				LessonDetailView.ViewModel(
					id: "Information",
					sections: [
						LessonDetailView.ViewModel.Section(
							id: "name",
							title: "Type",
							detail: lesson.type.fullName ?? ""
						),
						LessonDetailView.ViewModel.Section(
							id: "auditory",
							title: "Auditory",
							detail: lesson.auditory
						)
					]
				)
			)

			viewModels.append(
				LessonDetailView.ViewModel(
					id: "Time",
					sections: [
						LessonDetailView.ViewModel.Section(
							id: "start",
							title: "start",
							detail: lesson.start.formatted(date: .abbreviated, time: .standard)
						),
						LessonDetailView.ViewModel.Section(
							id: "end",
							title: "end",
							detail: lesson.end.formatted(date: .abbreviated, time: .standard)
						)
					]
				)
			)

			if !lesson.teachers.isEmpty {
				viewModels.append(
					LessonDetailView.ViewModel(
						id: "Teacher",
						sections: lesson.teachers.map { teacher in
							LessonDetailView.ViewModel.Section(
								id: teacher.identifier,
								title: teacher.fullName,
								detail: ""
							)
						}
					)
				)
			}

			viewModels.append(
				LessonDetailView.ViewModel(
					id: "Groups",
					sections: lesson.groups.map { group in
						LessonDetailView.ViewModel.Section(
							id: group.identifier,
							title: group.name,
							detail: ""
						)
					}
				)
			)

			return (lesson.subject.title ?? "", viewModels)
		} catch {
			return ("", [])
		}
	}
}
