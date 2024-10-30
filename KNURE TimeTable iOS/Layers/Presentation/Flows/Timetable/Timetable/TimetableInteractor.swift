//
//  TimetableInteractor.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 22/12/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

@MainActor
protocol TimetableInteractorInput {
	func updateTimetable(identifier: String) async throws
}


@MainActor
final class TimetableInteractor: TimetableInteractorInput {

//	private let updateTimetableUseCase: UpdateTimetableUseCase

//	init(updateTimetableUseCase: UpdateTimetableUseCase) {
//		self.updateTimetableUseCase = updateTimetableUseCase
//	}

	// MARK: - TimetableInteractorInput

	func updateTimetable(identifier: String) async throws {
//		_ = updateTimetableUseCase.execute(identifier)
	}
}
