//
//  KNURERequestBuilder.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 23/02/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension KNURE {

	struct Request {

		static func make(endpoint: Endpoint) throws -> URLRequest {
			var components: URLComponents = .init()
			components.host = "cist.nure.ua"
			components.scheme = "https"
			switch endpoint {
				case let .timetable(type, identifier):
					components.path = "/ias/app/tt/P_API_EVENT_JSON"
					components.queryItems = [
						URLQueryItem(name: "timetable_id", value: identifier),
						URLQueryItem(name: "type_id", value: "\(type.rawValue)")
				]

				case let .item(type) where type == .group:
					components.path = "/ias/app/tt/P_API_GROUP_JSON"

				case let .item(type) where type == .teacher:
					components.path = "/ias/app/tt/P_API_PODR_JSON"

				case let .item(type) where type == .auditory:
					components.path = "/ias/app/tt/P_API_AUDITORIES_JSON"

				case .item:
					break
			}

			guard let url = components.url else { throw URLError(.badURL) }

			return URLRequest(url: url)
		}
	}
}

extension KNURE.Request {

	enum Endpoint {
		case timetable(Item.Kind, String)
		case item(Item.Kind)
	}
}
