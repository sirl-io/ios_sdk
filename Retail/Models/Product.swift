//
//  Product.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation

public struct Product: Decodable {
    public var id: String?
    public var name: String?
    public var image: String?
    public var createdOn: String?
    public var updatedOn: String?
    public var sourceId: String?

    public init(id: String? = nil, name: String? = nil,
                image: String? = nil, createdOn: String? = nil, updatedOn: String? = nil, sourceId: String?) {
        self.id = id
        self.name = name
        self.image = image
        self.createdOn = createdOn
        self.updatedOn = updatedOn
        self.sourceId = sourceId
    }

}
