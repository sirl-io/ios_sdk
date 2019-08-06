//
//  UserLogin.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/11/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public struct UserLogin: APIRequest {

    public typealias Response = User

    public typealias RequestBody = UserCredentials

    public var requestBody: UserCredentials {
        return mUserCredentials!
    }
    public var resourceName: String {
        return "Users/login"
    }

    public var requestMethod: String {
        return "POST"
    }

    let mUserCredentials: UserCredentials?

    public init(userCredentials: UserCredentials) {
        self.mUserCredentials = userCredentials
    }

}
