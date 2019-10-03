//
//  Product.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public class Coupon: Decodable {
    public var id: Int?
    public var title: String?
    public var description: String?
    public var finePrint: String?
    public var updatedOn: String?
    public var type: String?
    public var ttlSeconds: Int?
    public var code: String?
    public var expiration: Date?

    public var isClaimable: Bool {
        get {
            guard type != nil else {
                if(type == "Raffle") {
                    return false
                }

                return true
            }
            return true
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case finePrint
        case updatedOn
        case type
        case ttlSeconds
        case code
        case couponUsageLog
    }
    enum CouponUsageLogKeys: String, CodingKey {
        case couponCode
        case expires
    }

    public init(id: Int? = nil,
                title: String? = nil,
                description: String? = nil,
                finePrint: String? = nil,
                updatedOn: String? = nil,
                type: String? = nil,
                ttlSeconds: Int? = nil,
                code: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.finePrint = finePrint
        self.updatedOn = updatedOn
        self.type = type
        self.ttlSeconds = ttlSeconds
        self.code = code
    }

    required public init(from decoder: Decoder) throws {
       let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        finePrint = try values.decodeIfPresent(String.self, forKey: .finePrint)
        ttlSeconds = try values.decodeIfPresent(Int.self, forKey: .ttlSeconds)
        if let updatedOn = try values.decodeIfPresent(String.self, forKey: .updatedOn) {
            self.updatedOn = updatedOn
        }

        if let type = try values.decodeIfPresent(String.self, forKey: .type) {
            self.type = type
        }

        if(values.contains(.couponUsageLog)) {
            let usage = try values.nestedContainer(keyedBy: CouponUsageLogKeys.self, forKey: .couponUsageLog)
            code = try usage.decodeIfPresent(String.self, forKey: .couponCode)
            expiration = try usage.decodeIfPresent(Date.self, forKey: .expires)
        }
    }
}
