//
//  SirlUserMeta.swift
//  SirlSDK
//
//  Created by Wei Cai on 7/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public class SirlUserMeta: Codable, Cachable {

    public typealias CacheType = SirlUserMeta

    public var firstName: String?
    public var lastName: String?
    public var email: String?
    public var mobile: String?

    public init(firstName: String?=nil,
                lastName: String?=nil,
                email: String?=nil,
                mobile: String?=nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.email = email
    }

    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case email
        case mobile
    }

    enum infoContainerKey: String, CodingKey {
        case info
    }

    enum infoKeys: String, CodingKey {
        case email
        case fname
        case lname
        case mobile
    }

    public static func decode(_ data: Data) -> SirlUserMeta? {
        return try? JSONDecoder().decode(SirlUserMeta.self, from: data)
    }

    public func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(mobile, forKey: .mobile)
    }

    public required convenience init(from decoder: Decoder) throws {
        let infoContainer = try decoder.container(keyedBy: infoContainerKey.self)
        let info = try infoContainer.nestedContainer(keyedBy: infoKeys.self, forKey: .info)
        let firstname = try info.decodeIfPresent(String.self, forKey: .fname)
        let lastname = try info.decodeIfPresent(String.self, forKey: .lname)
        let email = try info.decodeIfPresent(String.self, forKey: .email)
        let mobile = try info.decodeIfPresent(String.self, forKey: .mobile)
        self.init(firstName: firstname, lastName: lastname, email: email, mobile: mobile)
    }

}
