//
//  RouteNodes.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/21/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SirlCoreSDK)
import SirlCoreSDK
#endif

public struct RouteNode: Decodable {
    private let xLocation: Double!
    private let yLocation: Double!
    public var location: sirlLocation {
        return sirlLocation(x: xLocation, y: yLocation, z: 0)
    }

    public init(x: Double, y: Double) {
        self.xLocation = x
        self.yLocation = y
    }

    private enum CodingKeys: String, CodingKey {
        case x = "xLoc"
        case y = "yLoc"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Double.self, forKey: .x)
        let y = try container.decode(Double.self, forKey: .y)
        self.init(x: x, y: y)
    }

}
