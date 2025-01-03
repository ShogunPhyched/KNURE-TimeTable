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
		let id: Int64
		let shortName: String
		let fullName: String
		@Omissible var directions: [Direction]
		@Omissible var departments: [Department]
	}
}

extension KNURE.Response.University {
	var groups: [KNURE.Response.Section] {
		return faculties
			.map { faculty in
				KNURE.Response.Section(
					name: faculty.shortName,
					items: faculty.directions.reduce([]) { result, current in
						result + current.groups.map {
							Item(
								identifier: String($0.id),
								shortName: $0.name,
								fullName: nil,
								type: .group,
								selected: false,
								updated: nil
							)
						}
					}
				)
			}
	}

	var teachers: [KNURE.Response.Section] {
		return faculties
			.map { faculty in
				KNURE.Response.Section(
					name: faculty.shortName,
					items: faculty.departments.reduce([]) { result, current in
						result + current.teachers.map {
							Item(
								identifier: String($0.id),
								shortName: $0.shortName,
								fullName: $0.fullName,
								type: .teacher,
								selected: false,
								updated: nil
							)
						}
					}
				)
			}
	}

	var auditories: [KNURE.Response.Section] {
		return buildings
			.map { building in
				KNURE.Response.Section(
					name: building.shortName,
					items: building.auditories.map {
						Item(
							identifier: $0.id,
							shortName: $0.shortName,
							fullName: nil,
							type: .auditory,
							selected: false,
							updated: nil
						)
					}
				)
			}
	}
}

extension KNURE.Response {
	struct Section {
		let name: String
		let items: [Item]
	}
}
