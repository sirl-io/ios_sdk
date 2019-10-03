//
//  GetRouteToProduct.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/21/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct GetRouteToLocation: APIRequest {

    public typealias Response = [RouteNode]
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "nodes/route"
    }

    public var requestMethod: String {
        return "GET"
    }

    public var requestBody: NULLCodable {
        return NULLCodable()
    }

    public let mlId: Int?
    public let routeTo: String?
    public let xCurrent: Double?
    public let yCurrent: Double?

    public init(mlId: Int? = nil, destinations: [sirlLocation]? = nil, currentLocation: sirlLocation? = nil) {
        self.mlId = mlId
        self.xCurrent = currentLocation?.x
        self.yCurrent = currentLocation?.y
        guard let mDest = destinations else {
            self.routeTo = nil
            return
        }
        var output = "["
        for location in mDest {
            output = output + location.xyString + ","
        }
        if output.last == "," {
            output.removeLast()
        }
        output = output + "]"
        self.routeTo = output
    }

}
