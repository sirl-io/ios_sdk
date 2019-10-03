//
//  GetLocationMap.swift
//  SirlSDK
//
//  Created by Wei Cai on 6/1/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct GetLocationMap: APIRequest {

    public typealias Response = SirlMapObject
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "locations/getMap"
    }

    public var requestMethod: String {
        return "GET"
    }

    public var requestBody: NULLCodable {
        return NULLCodable()
    }

    let mlId: Int?

    public init(mapId: Int? = nil) {
        self.mlId = mapId

    }

}
