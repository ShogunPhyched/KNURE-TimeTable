//
//  ImportService.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 08/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

/// Provide basic interface for data import
/// DI should resolve this interface with implementation for specific data model
protocol ImportService: Sendable {

	/// Import data with completion
	///
	/// - Parameters:
	///   - data: data to import
	///   - completion: signal for import is over
	///   - info: additinal information for decoding, such as predicate keys
	/// - Returns: Void
	/// - Throws: throws error if something goes wrong
	func decode(_ data: Data, info: [String: String]) async throws
}
