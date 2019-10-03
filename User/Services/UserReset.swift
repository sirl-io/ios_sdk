//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 6/20/19.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public struct UserReset: APIRequest {

    public typealias Response = NULLCodable

    public typealias RequestBody = UserReset

    public var requestBody: UserReset {
        return self
    }
    public var resourceName: String {
        return "Users/reset"
    }

    public var requestMethod: String {
        return "POST"
    }

    let login: String?

    public init(login: String?) {
        self.login = login
    }

}
