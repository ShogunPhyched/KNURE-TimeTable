//
//  Formatters.swift
//  KNURE TimeTable
//
//  Created by Vladislav Chapaev on 09.11.2024.
//  Copyright © 2024 Vladislav Chapaev. All rights reserved.
//

import Foundation

enum Formatters {

	static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		return formatter
	}()

	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, dd MMMM"
		return formatter
	}()
}
