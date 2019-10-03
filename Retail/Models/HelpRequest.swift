//
//  HelpRequest.swift
//  SirlSDK
//
//  Created by Wei Cai on 9/10/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public class HelpRequestRespond: Decodable {
    public var requestStatus: Bool?

    public init(requestStatus: Bool = false) {
        self.requestStatus = requestStatus
    }

}
