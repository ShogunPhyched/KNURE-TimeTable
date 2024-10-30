//
//  Data+EncodingTransformation.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 10/02/2019.
//  Copyright © 2019 Vladislav Chapaev. All rights reserved.
//

import Foundation

extension Data {

	func transform(
		from sourceEncoding: String.Encoding,
		to resultEncoding: String.Encoding
	) throws -> Data {

		guard let response = String(data: self, encoding: sourceEncoding)?.data(using: resultEncoding) else {
			throw Error.transformation
		}

		let range = Range<Data.Index>(0...response.count - 1)
		return response.subdata(in: range)
    }

	enum Error: LocalizedError {
		case transformation
	}
}
