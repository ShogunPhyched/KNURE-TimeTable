//
//  Sequence+Grouping.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 16.11.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

extension Sequence {
	func grouped<T: Equatable>(by block: (Element) throws -> T) rethrows -> [[Element]] {
		return try reduce(into: []) { result, element in
			if let lastElement = result.last?.last, try block(lastElement) == block(element) {
				result[result.index(before: result.endIndex)].append(element)
			} else {
				result.append([element])
			}
		}
	}
}
