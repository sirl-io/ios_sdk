//
//  CouponServiceDelegate.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 10/31/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation

@objc public protocol CouponViewDelegate: class {
    @objc optional func didDismissCoupon(id: Int)
    @objc optional func didClickEmailRegistration(at index: Int)
    @objc optional func didLoadCoupons()
}

@objc public protocol CouponServiceDelegate: class {
    @objc optional func didDismissCoupon(id: Int)
    @objc optional func didClickEmailRegistration(at index: Int)
}
