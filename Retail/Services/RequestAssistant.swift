//
//  RequestAssistant.swift
//  SirlSDK
//
//  Created by Wei Cai on 9/10/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct RequestAssistant: APIRequest {

    public typealias Response = HelpRequestRespond
    public typealias RequestBody = NULLCodable

    public var requestBody: NULLCodable {
        return NULLCodable()
    }
    public var resourceName: String {
        return "activeEmployees/requestHelp"
    }

    public var requestMethod: String {
        return "GET"
    }

    let mlId: Int?
    let customerFcmToken: String?
    let xLoc: Double?
    let yLoc: Double?

    public init(ML_ID: Int, FCM_token: String, location: sirlLocation) {
        self.mlId = ML_ID
        self.customerFcmToken = FCM_token
        self.xLoc = location.x
        self.yLoc = location.y
    }

}
