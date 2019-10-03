//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 8/19/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct FetchPromotions: APIRequest {

    public typealias Response = StorePromotions
    public typealias RequestBody = NULLCodable

    public var requestBody: NULLCodable {
        return NULLCodable()
    }
    public var resourceName: String {
        return "stores/\(self.storeId ?? 0)/v1/promotions"
    }

    public var requestMethod: String {
        return "GET"
    }

    private var storeId: Int!

    public func encode(to encoder: Encoder) throws {
        // try not to encode storeId
    }

    public init(storeId: Int) {
       self.storeId = storeId
    }

}
