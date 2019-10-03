//
//  User.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/11/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class User: Codable, Cachable {

    public typealias CacheType = User

    public var id: String?
    public var ttl: Int?
    public var created: Date?
    public var userId: String?
    public var principalType: String?

    public init(id: String?, ttl: Int?, created: Date?, userId: String?, principalType: String?) {
        self.id = id
        self.ttl = ttl
        self.created = created
        self.userId = userId
        self.principalType = principalType
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case ttl
        case created
        case userId
        case principalType
    }

    public static func decode(_ data: Data) -> User? {
        return try? JSONDecoder().decode(User.self, from: data)
    }

    public func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ttl, forKey: .ttl)
        try container.encode(created, forKey: .created)
        try container.encode(userId, forKey: .userId)
        try container.encode(principalType, forKey: .principalType)
    }

}
