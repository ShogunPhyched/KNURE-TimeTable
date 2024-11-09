//
//  MockJSONLoader.swift
//  KNURE TimeTable iOS Tests
//
//  Created by Vladislav Chapaev on 24/10/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Foundation

final class MockJSONLoader {

	enum ItemType: String {
		case groups, teachers, auditories
	}

	static func load(json named: String, item type: ItemType) -> Data {
		let bundle = Bundle(for: MockJSONLoader.self)
		let path = bundle.path(forResource: "Mocks/KNURE/\(type.rawValue)/\(named)", ofType: "json")
		return NSData(contentsOfFile: path!)! as Data
	}
}

extension Item.Kind {
	var cast: MockJSONLoader.ItemType {
		switch self {
			case .group: return .groups
			case .teacher: return .teachers
			case .auditory: return .auditories
		}
	}
}
