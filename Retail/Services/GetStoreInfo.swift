//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 10/17/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class StoreInfomation {
    public static var shared = StoreInfomation()
    public func getInfo(mlId: Int, completion: ((StoreInfo?) -> Void)?) {
        SirlAPIClient.shared.send(StoreInfoRequest(mlId: mlId)) { (res) in
            switch res {
            case .failure:
                completion?(nil)
                return
            case .success(let result):
                completion?(result)
            }
        }
    }
}

@available(iOS 10.0, *)
struct StoreInfoRequest: APIRequest {
    public typealias Response = StoreInfo
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "locations/\(self.mlId ?? 0)/store"
    }

    public var requestMethod: String {
        return "GET"
    }

    private var mlId: Int!

    public var requestBody: NULLCodable {
        return NULLCodable()
    }

    public init(mlId: Int) {
        self.mlId = mlId
    }

    public func encode(to encoder: Encoder) throws {
        // try not to encode mlId
    }

    }
