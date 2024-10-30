//
//  UseCase.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 12/05/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

/// UseCase represent basic unit of bisness logic
protocol UseCase<Request, Response>: Sendable {

	associatedtype Request: Sendable
	associatedtype Response: Sendable

	/// command to execute use case
	///
	/// - Parameter request: input type
	/// - Returns: promise output type
	func execute(_ request: Request) async throws -> Response
}
