//
//  CouponService.swift
//  pipsSDKDev
//
//  Created by Bart Shappee on 4/25/19.
//  Copyright © 2019 SIRL. All rights reserved.
//

import Foundation
import UIKit
import os.log
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class SIRLCouponService {

    public static let shared = SIRLCouponService()
    private let mLog = OSLog(subsystem: "com.sirl.coupon.service", category: "Sirl Coupon Service")
    private let apiClient =  SirlAPIClient.shared

    let couponButton: CouponButton = {
        let cb = CouponButton()
        cb.translatesAutoresizingMaskIntoConstraints = false
        return cb
    }()

    let couponView: CouponView = {
        let view = CouponView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var couponViewHeight: CGFloat? {
        didSet {
            if let height =  couponViewHeight {
                couponViewHeightConstraint = self.couponView
                    .heightAnchor
                    .constraint(equalToConstant: height)
            }
        }
    }

    var couponViewHeightConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            couponViewHeightConstraint?.isActive = true
        }
    }

    public func getAvailableCoupons(completion: @escaping (_ coupons: [Coupon] ) -> Void) {
        self.apiClient.send(GetAvailableCoupons( mlId: SirlCore.shared.ML_ID )) { (res) in
            var coupons: [Coupon] = []
            switch res {
            case .failure(let error):
                os_log("Error getting available coupons : %@", log: self.mLog, type: .error, error.localizedDescription)
            case .success(let val):
                os_log("Coupons fetched", log: self.mLog, type: .debug)
                coupons = val
            }

            completion(coupons)
        }
    }

    public func claimCoupons(with: Coupon, completion: @escaping (_ calimed_coupon: Coupon? ) -> Void) {

        self.apiClient.send(UseCoupon( mlId: SirlCoreImpl.shared.ML_ID,
                                       coupon: with )) { (res) in
            var claimed_coupon: Coupon?

            switch res {
            case .failure(let error):
                os_log("Error claiming coupon : %@", log: self.mLog, type: .error, error.localizedDescription)

            case .success(let val):
                claimed_coupon = with
                claimed_coupon?.code = val.couponCode
                claimed_coupon?.expiration = val.expires
            }

            completion( claimed_coupon )
        }
    }
}

@available(iOS 10.0, *)
extension SIRLCouponService {

    public func addDefaultView(to view: UIView, above subview: UIView? = nil) {
        view.addSubview(couponButton)
        view.addSubview(couponView)
        if let aboveView = subview,
           aboveView.isDescendant(of: view) {
            self.couponView.bottomAnchor.constraint(equalTo: aboveView.topAnchor).isActive = true
        } else {
            self.couponView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        self.couponView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.couponView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        self.couponViewHeight = 0
        self.couponButton.bottomAnchor.constraint(equalTo: self.couponView.topAnchor).isActive = true
        self.couponButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.couponButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.couponButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        setupButtonActions()
    }

    //TODO Investigate if this is actually used
    public func loadCoupons() {
        if couponView.superview != nil {
            couponView.loadAvailableCoupons {
                DispatchQueue.main.async {
                    if self.couponView.areCouponsAvalible {
                        if self.couponButton.superview != nil {
                            self.couponButton.isHidden = false
                            self.couponButton.notifiyAvailbility()
                        }
                    } else {
                        self.couponButton.isHidden = true
                    }
                }
            }
        }
    }

    private func setupButtonActions() {
        self.couponButton.button.addTarget(self, action: #selector(showCoupons), for: .touchUpInside)
    }

    @objc private func showCoupons() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (_) in
            if self.couponButton.isOpen {
                self.couponViewHeight = 200
            } else {
                self.couponViewHeight = 0
            }
            UIView.animate(withDuration: 0.5) {
                self.couponView.superview?.layoutIfNeeded()
            }
        }

    }
}
