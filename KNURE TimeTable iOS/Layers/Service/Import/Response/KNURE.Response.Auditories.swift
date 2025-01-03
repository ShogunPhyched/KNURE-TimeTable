//
//  KNURE.Response.Auditories.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 04/11/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

extension KNURE.Response.University {
	struct Building: Decodable {
		let id: String
		let shortName: String
		let fullName: String
		@Omissible var auditories: [Auditory]
	}
}

extension KNURE.Response.University.Building {
	struct Auditory: Decodable {
		let id: String
		let shortName: String
	}
}
