//
//  Convertable.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 04/06/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

/// Declares that entity can be converted to another type
///
/// Typically used to convert an NSManagedObject instance to a local data transfer object or business layer model
protocol Convertable: AnyObject {

	associatedtype NewType: Sendable

	/// Command for synchronous value conversion. Return nil if conversion failed
	func convert() -> NewType?
}
