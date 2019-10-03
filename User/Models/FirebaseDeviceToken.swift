//
//  FirebaseMessageToken.swift
//  SirlSDK
//
//  Created by Wei Cai on 12/14/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public struct FirebaseDeviceToken: Codable {
    public var fcmToken: String
    public init(fcmToken: String) {
        self.fcmToken = fcmToken
    }
}
