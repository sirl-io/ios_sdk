//
//  UserCredentials.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/11/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public struct UserCredentials: Encodable {
    var login: String?
    var password: String?

    public init(login: String, password: String) {
        self.login = login
        self.password = password
    }
}
