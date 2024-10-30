//
//  CoreDataService.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 24/03/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import CoreData
import Combine

/// Basic CoreData service
protocol CoreDataService: Sendable {

	/// Observable for request
	///
	/// - Parameter request: NSFetchRequest
	/// - Returns: Observable fetch result
	func observe<T, R: Sendable>(_ request: NSFetchRequest<T>) -> AnyPublisher<[R], Never>
		where T: NSFetchRequestResult & Convertable, R == T.NewType
	
	/// <#Description#>
	/// - Parameters:
	///   - request: <#request description#>
	///   - sectionNameKeyPath: <#sectionNameKeyPath description#>
	/// - Returns: <#description#>
	func observe<T>(
		_ request: NSFetchRequest<T>,
		sectionNameKeyPath: String?
	) -> AnyPublisher<[Publishers.SectionedEntity<T>.Section], Never> where T: NSFetchRequestResult & Convertable

	/// <#Description#>
	/// - Parameters:
	///   - request: <#request description#>
	///   - convert: <#convert description#>
	func fetch<T, R: Sendable>(
		_ request: NSFetchRequest<T>,
		_ convert: @escaping @Sendable (T) -> R?
	)  async throws -> [R]

	/// <#Description#>
	/// - Parameter request: <#request description#>
	func delete<T: NSManagedObject>(_ request: NSFetchRequest<T>) async throws

	/// <#Description#>
	/// - Parameter request: <#request description#>
	func perform(_ closure: @escaping (NSManagedObjectContext) throws -> Void) async throws
}
