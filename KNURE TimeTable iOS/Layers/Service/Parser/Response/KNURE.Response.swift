//
//  KNURE.Response.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 15/11/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

extension KNURE {
	struct Response: Decodable {
		let university: University
	}
}

extension KNURE.Response {
	struct University: Decodable {
		@Omissible var faculties: [Faculty]
		@Omissible var buildings: [Building]
	}
}

extension KNURE.Response.University {
	struct Faculty: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
		@Omissible var directions: [Direction]
		@Omissible var departments: [Department]
	}
}

extension KNURE.Response.University {
	var groups: [Item] {
		return faculties
			.flatMap { $0.directions }
			.reduce([]) { result, current in
				result + current.groups.map {
					Item(
						identifier: "\($0.id)",
						shortName: $0.name,
						fullName: nil,
						type: .group,
						selected: false,
						hint: current.fullName,
						updated: nil
					)
				}
			}
	}

	var teachers: [Item] {
		return faculties
			.flatMap { $0.departments }
			.reduce([]) { result, current in
				result + current.teachers.map {
					Item(
						identifier: "\($0.id)",
						shortName: $0.shortName,
						fullName: $0.fullName,
						type: .teacher,
						selected: false,
						hint: current.fullName,
						updated: nil
					)
				}
			}
	}

	var auditories: [Item] {
		return buildings
			.reduce([]) { result, current in
				result + current.auditories.map {
					Item(
						identifier: $0.id,
						shortName: $0.shortName,
						fullName: nil,
						type: .auditory,
						selected: false,
						hint: current.fullName,
						updated: nil
					)
				}
			}
	}
}
