//
//  ItemRepository.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Combine
import Foundation

/// Access to timetable items
protocol ItemRepository: Sendable {

	/// <#Description#>
	/// - Returns: <#description#>
	func localAddedItems() -> AnyPublisher<[Item], Never>
	
	/// <#Description#>
	/// - Returns: <#description#>
	func localAddedItemsIdentifiers() async throws -> [String]

    /// Save item in persistent store
    ///
    /// - Parameter items: timetable item
    /// - Returns: Promise with finished operation
	func local(add items: [Item]) async throws

    /// Delete item from persistent store
    ///
    /// - Parameter identifier: item identifier
    /// - Returns: Promise with finished operation
	func local(delete identifier: String) async throws
	
	/// <#Description#>
	/// - Parameter identifier: <#identifier description#>
	func local(select identifier: String) async throws

	/// <#Description#>
	/// - Parameter type: <#type description#>
	func remote(items type: Item.Kind) async throws -> [Item]
}
