//
//  AddStoreProduct.swift
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
public struct AddStoreProduct: APIRequest {

    public typealias Response = StoreProduct

    public typealias RequestBody = StoreProduct

    public var requestBody: StoreProduct {
        return mStoreProduct!
    }
    public var resourceName: String {
        return "items"
    }

    public var requestMethod: String {
        return "POST"
    }

    let mStoreProduct: StoreProduct?

    public init(storeProduct: StoreProduct) {
        self.mStoreProduct = storeProduct
    }

}
