//
//  GetUserInfo.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 6/18/19.
//  Copyright © 2019 Sirl Inc. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public struct GetUserInfo: APIRequest {

    public typealias Response = SirlUserMeta
    public typealias RequestBody = NULLCodable

    public var resourceName: String {
        return "Users/getInfo"
    }

    public var requestMethod: String {
        return "GET"
    }

    public var requestBody: NULLCodable {
        return NULLCodable()
    }
}
