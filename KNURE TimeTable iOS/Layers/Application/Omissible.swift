//
//  Omissible.swift
//  KNURE TimeTable iOS
//
//  Created by Vladislav Chapaev on 11/10/2020.
//  Copyright © 2020 Vladislav Chapaev. All rights reserved.
//

/// Wrapper for Decodable type, that omits failed values in Decodable array
@propertyWrapper struct Omissible<T: Decodable> {

	var wrappedValue: [T] = []
}

extension Omissible: Decodable {
	private struct Dummy: Decodable { }

	init(from decoder: Decoder) throws {
		guard var container = try? decoder.unkeyedContainer() else { return }
		while !container.isAtEnd {
			if let decoded = try? container.decodeIfPresent(T.self) {
				wrappedValue.append(decoded)
			} else {
				_ = try? container.decodeIfPresent(Dummy.self)
			}
		}
	}
}

extension KeyedDecodingContainer {
	func decode<T>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> T
		where T: Decodable, T: OmissibleType {
			return try decodeIfPresent(T.self, forKey: key) ?? T.defaultValue
    }
}

protocol OmissibleType {
    static var defaultValue: Self { get }
}

extension Omissible: OmissibleType {
    static var defaultValue: Self { .init(wrappedValue: [])}
}
