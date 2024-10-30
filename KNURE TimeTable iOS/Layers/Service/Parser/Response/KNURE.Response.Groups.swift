//
//  KNURE.Response.Groups.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 04/11/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

extension KNURE.Response.University.Faculty {
	struct Direction: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
		@Omissible var groups: [Group]
		@Omissible var specialities: [Direction]
	}
}

extension KNURE.Response.University.Faculty.Direction {
	struct Speciality: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
		@Omissible var groups: [Group]
	}

	struct Group: Decodable {
		let id: Int
		let name: String
	}
}
