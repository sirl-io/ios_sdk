//
//  SirlUserDelegate.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 9/23/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation

@objc public protocol SirlUserDelegate: class {
    @objc optional func didChangeLoginStatus(status: Bool)
}
