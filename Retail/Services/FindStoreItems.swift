//
//  FindStoreItems.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/8/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct FindStoreItems: APIRequest {

    public typealias Response = [StoreProduct]
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "items"
    }

    public var requestMethod: String {
        return "GET"
    }

    public var requestBody: NULLCodable {
        return NULLCodable()
    }

    let filter: String?

    public init(storeId: Int, productIds: [String] = [String]()) {
        var or = String()
        for (index, productId) in productIds.enumerated() {
            or += "{\"productId\":\"\(productId)\"}"
            if index < productIds.count - 1 {
                or += ","
            }
        }
        let and = "[{\"or\":["+or+"]},{\"storeId\":\"\(storeId)\"}]"
        self.filter = "{\"where\":{\"and\":"+and+"}}"

    }

}
