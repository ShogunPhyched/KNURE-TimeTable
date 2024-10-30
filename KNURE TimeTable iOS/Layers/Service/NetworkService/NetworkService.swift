//
//  NetworkService.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 27/02/2021.
//  Copyright © 2021 Vladislav Chapaev. All rights reserved.
//

import Combine
import Foundation

struct NetworkResponse: Sendable {
	let status: HTTP.Status
	let data: Data
}

protocol NetworkService: Sendable {

	func execute(_ request: URLRequest) async throws -> NetworkResponse

	func validate(_ response: NetworkResponse) throws -> Data
}

final class NetworkServiceImpl {

	private let session: URLSession

	init(configuration: URLSessionConfiguration = .default) {
		session = .init(configuration: configuration, delegate: nil, delegateQueue: nil)
	}
}

extension NetworkServiceImpl: NetworkService {

	func execute(_ request: URLRequest) async throws -> NetworkResponse {
		let result = try await session.data(for: request)
		return try transform(data: result.0, response: result.1)
	}

	func validate(_ response: NetworkResponse) throws -> Data {
		guard response.status == .ok else { throw response.status }
		return response.data
	}

	private func transform(data: Data, response: URLResponse) throws -> NetworkResponse {
		guard
			let status = response as? HTTPURLResponse,
			let statusCode = HTTP.Status(rawValue: status.statusCode)
		else {
			throw URLError(.badServerResponse)
		}

		return NetworkResponse(status: statusCode, data: data)
	}
}
