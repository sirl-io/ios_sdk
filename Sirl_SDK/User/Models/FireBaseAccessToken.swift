//
//  FireBaseAccessToken.swift
//  SirlSDK
//
//  Created by Wei Cai on 7/2/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public struct FireBaseAccessToken: Decodable {
    public var token: String
    public init(token: String) {
        self.token = token
    }
}
