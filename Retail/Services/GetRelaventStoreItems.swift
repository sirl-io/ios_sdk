//
//  getRelaventStoreItems.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct GetRelaventStoreItems: APIRequest {

    public typealias Response = [StoreProduct]
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "items/someItems"
    }

    public var requestMethod: String {
        return "GET"
    }

    public var requestBody: NULLCodable {
        return NULLCodable()
    }

    let partialText: String?
    let mlId: Int?

    public init(partialText: String? = nil, mlId: Int? = nil) {
        self.partialText = partialText
        self.mlId = mlId
    }

}
