//
//  KNURE.Response.Teachers.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 04/11/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

extension KNURE.Response.University.Faculty {
	struct Department: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
		@Omissible var teachers: [Teacher]
	}
}

extension KNURE.Response.University.Faculty.Department {
	struct Teacher: Decodable {
		let id: Int
		let shortName: String
		let fullName: String
	}
}
