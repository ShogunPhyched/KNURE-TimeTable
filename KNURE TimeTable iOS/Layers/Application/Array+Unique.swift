//
//  Array+Unique.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 03.01.2025.
//  Copyright © 2025 Vladislav Chapaev. All rights reserved.
//

extension Array where Element: Equatable {
	var unique: [Element] {
		var uniqueValues: [Element] = []
		forEach { item in
			guard !uniqueValues.contains(item) else { return }
			uniqueValues.append(item)
		}
		return uniqueValues
	}
}
