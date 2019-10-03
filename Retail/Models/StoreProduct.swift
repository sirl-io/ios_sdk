//
//  StoreProduct.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

public class StoreProduct: Codable {
    public var id: Int?
    public var mlId: Int?
    public var productId: String?
    public var createdOn: String?
    public var updatedOn: String?
    public var xLoc: Double?
    public var yLoc: Double?
    public var zLoc: Double?
    public var product: Product?

    public var location: sirlLocation? {
        if let x = xLoc, let y = yLoc, let z = zLoc {
            return sirlLocation(x: x, y: y, z: z)
        }
        return nil
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case mlId
        case productId
        case createdOn
        case updatedOn
        case xLoc
        case yLoc
        case zLoc
        case product
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(mlId, forKey: .mlId)
        try container.encode(productId, forKey: .productId)
        try container.encode(createdOn, forKey: .createdOn)
        try container.encode(updatedOn, forKey: .updatedOn)
        try container.encode(xLoc, forKey: .xLoc)
        try container.encode(yLoc, forKey: .yLoc)
        try container.encode(zLoc, forKey: .zLoc)
    }

    public init(mlId: Int? = nil, productId: String? = nil,
                xLoc: Double? = nil, yLoc: Double? = nil, zLoc: Double? = nil) {
        self.mlId = mlId
        self.productId = productId
        self.xLoc = xLoc
        self.yLoc = yLoc
        self.zLoc = zLoc
    }

}
