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
		formatter.timeZone = TimeZone(identifier: "Europe/Kiev")
		return formatter
	}()

	static let verticalDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE, dd MMMM"
		return formatter
	}()

	static let horizontalDate: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM, EE"
		return formatter
	}()

	static let itemFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy, HH:mm:ss"
		return formatter
	}()
}
