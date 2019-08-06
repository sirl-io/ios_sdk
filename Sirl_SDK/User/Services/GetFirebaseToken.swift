//
//  GetFirebaseToken.swift
//  SirlSDK
//
//  Created by Wei Cai on 7/2/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public struct GetFirebaseToken: APIRequest {

    public typealias Response = FireBaseAccessToken

    public typealias RequestBody = FirebaseDeviceToken?

    public var requestBody: FirebaseDeviceToken? {
        return fcmToken
    }
    public var resourceName: String {
        return "Users/loginToFirebase"
    }

    public var requestMethod: String {
        return "POST"
    }

    let fcmToken: FirebaseDeviceToken?

}
