//
//  HTTP.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Foundation

struct HTTP { }

extension HTTP {

	enum Status: Int, Error, Sendable {

		// MARK: - Informational - 1xx

		case `continue` = 100
		case switchingProtocols = 101
		case processing = 102

		// MARK: - Success - 2xx

		case ok = 200
		case created = 201
		case accepted = 202
		case nonAuthoritativeInformation = 203
		case noContent = 204

		// MARK: - Redirection - 3xx

		case notModified = 304

		// MARK: - Client Error - 4xx

		case badRequest = 400
		case unauthorized = 401
		case forbidden = 403
		case notFound = 404

		// MARK: - Server Error - 5xx

		case internalServerError = 500
		case notImplemented = 501
		case badGateway = 502
		case serviceUnavailable = 503
		case gatewayTimeout = 504

		case undefined = -1
	}

	enum Method: String {
		case GET
		case POST
		case PUT
		case PATCH
		case DELETE
	}
}

extension HTTPURLResponse {
	var status: HTTP.Status {
		return HTTP.Status(rawValue: statusCode) ?? .undefined
	}
}
