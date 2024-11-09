//
//  Subscribing.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 30.09.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Combine

protocol Subscribing<Request, Response>: Sendable {

	associatedtype Request
	associatedtype Response

	func subscribe(_ request: Request) -> AnyPublisher<Response, Never>
}
