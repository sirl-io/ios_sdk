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
struct GetAvailableCoupons: APIRequest {
    public typealias Response = [Coupon]
    public typealias RequestBody = GetAvailableCoupons

    let installationUuid: String?
    let location: UInt32?

    init(mlId location: UInt32?) {
        let currentDevice = UIDevice.current
        self.installationUuid = currentDevice.identifierForVendor?.uuidString

        self.location = location
    }

    public var requestBody: RequestBody {
        return self
    }

    public var resourceName: String {
        return "couponUsageLog/checkEligible"
    }

    public var requestMethod: String {
        return "GET"
    }

    private enum CodingKeys: String, CodingKey {
        case installationUuid
        case mlId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if let id = location {
            try container.encode(id, forKey: .mlId)
        }

        if let uuid = installationUuid {
            try container.encode(uuid, forKey: .installationUuid)
        }
    }
}
