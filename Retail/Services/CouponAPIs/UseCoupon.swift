//
//  CouponService.swift
//  pipsSDKDev
//
//  Created by Bart Shappee on 4/25/19.
//  Copyright © 2019 SIRL. All rights reserved.
//

import Foundation
import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
struct UseCoupon: APIRequest {
    typealias Response = UseResponse
    typealias RequestBody = UseCoupon

    struct UseResponse: Decodable {
        var id: Int
        var couponCode: String
        var expires: Date
    }

    let installationUuid: String?
    let location: UInt32?
    let couponId: Int?

    init(mlId location: UInt32?, coupon: Coupon) {
        let currentDevice = UIDevice.current
        self.installationUuid = currentDevice.identifierForVendor?.uuidString

        self.location = location
        self.couponId = coupon.id
    }

    public var requestBody: RequestBody {
        return self
    }
    public var resourceName: String {
        return "couponUsageLog/claim"
    }

    public var requestMethod: String {
        return "POST"
    }
    private enum CodingKeys: String, CodingKey {
        case installationUuid
        case mlId
        case couponId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let loc = location {
            try container.encode(loc, forKey: .mlId)
        }

        if let uuid = installationUuid {
            try container.encode(uuid, forKey: .installationUuid)
        }

        if let cid = couponId {
            try container.encode(cid, forKey: .couponId)
        }
    }
}
