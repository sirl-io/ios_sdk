//
//  StoreInfo.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 10/17/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

public class StoreInfo: Decodable {
    public var name: String!
    public var addesss: String!
    public var promotionsUrl: String?
    public var id: Int!
    public var location: SirlGeoLocation?
}

public class SirlGeoLocation: Decodable {
    public var lat: Double!
    public var lng: Double!
}
