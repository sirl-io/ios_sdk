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
    internal let ignoreList = "Sirl_CounponSerive_Ignore_List"
    public weak var delegate: CouponServiceDelegate?
    private var couponExpirationTimer: Timer?

    private var promotionCoupons: [Coupon] = [] {
        didSet {
            self.couponView.loadCoupons(from: promotionCoupons + coupons)
        }
    }

    private var coupons: [Coupon] = [] {
        didSet {
            self.couponView.loadCoupons(from: promotionCoupons + coupons)
        }
    }

    let couponButton: CouponButton = {
        let cb = CouponButton()
        cb.isHidden = true
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

    init() {
        self.couponView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    public func getAvailableCoupons(completion: @escaping (_ coupons: [Coupon] ) -> Void) {
        self.apiClient.send(GetAvailableCoupons( mlId: SirlCore.shared.ML_ID )) { (res) in
            var coupons: [Coupon] = []
            switch res {
            case .failure(let error):
                os_log("Error getting available coupons : %@", log: self.mLog, type: .error, error.localizedDescription)
            case .success(let val):
                os_log("Coupons fetched", log: self.mLog, type: .debug)
                let ignore = UserDefaults.standard.array(forKey: self.ignoreList) as? [Int]
                for coupon in val {
                    if let couponId = coupon.id,
                       let ignorelist = ignore,
                       ignorelist.contains(couponId) {
                       continue
                    }
                    if coupon.type == "Raffle" {
                        coupons.insert(coupon, at: 0)
                    } else {
                        coupons.append(coupon)
                    }
                }
            }
            completion(coupons)
        }
    }

    public func clearPromotionCoupons() {
        self.promotionCoupons.removeAll()
    }

    public func insertCoupon(at index: Int, coupon: Coupon) {
        self.coupons.insert(coupon, at: index)
    }

    public func addPromotionCoupon(promoCoupon: Coupon) {
        self.promotionCoupons.insert(promoCoupon, at: 0)
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

    public func addToIgnoreList(id: Int) {
        if var list = UserDefaults.standard.array(forKey: self.ignoreList) as? [Int] {
            if list.contains(id) {
                return
            }
            list.append(id)
            UserDefaults.standard.set(list, forKey: self.ignoreList)
        } else {
            UserDefaults.standard.set([id], forKey: self.ignoreList)
        }
    }

    private func handleExpiredCouponds() {
        let promoEarlistExp = clearExpiredAndFindEarlistExpirarion(coupons: &self.promotionCoupons)
        let couponEarlistExp = clearExpiredAndFindEarlistExpirarion(coupons: &self.coupons)
        if let promoEarlistExpiration = promoEarlistExp,
           let couponEarlistExpiration = couponEarlistExp {
            if promoEarlistExpiration < couponEarlistExpiration {
                resetCouponTimer(date: promoEarlistExpiration)
            } else {
                resetCouponTimer(date: couponEarlistExpiration)
            }
        } else {
            if let promoEarlistExpiration = promoEarlistExp {
                resetCouponTimer(date: promoEarlistExpiration)
            }
            if let couponEarlistExpiration = couponEarlistExp {
                 resetCouponTimer(date: couponEarlistExpiration)
            }
        }
    }

    private func resetCouponTimer(date: Date) {
        self.couponExpirationTimer?.invalidate()
        if let difference = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                            from: Date(), to: date).second {
            self.couponExpirationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(difference),
                                                              repeats: false, block: {
                (_) in
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                    self.handleExpiredCouponds()
                }
            })
        }
    }

    private func clearExpiredAndFindEarlistExpirarion(coupons:inout [Coupon]) -> Date? {
        var early: Date?
        var couponTemp = [Coupon]()
        for (index, coupon) in coupons.enumerated() {
            if let expiration = coupon.expiration {
                if  expiration > Date() {
                    couponTemp.append(coupon)
                    if early == nil {
                        early = expiration
                    } else {
                        if early! > expiration {
                            early = expiration
                        }
                    }
                }
            } else {
                couponTemp.append(coupon)
            }
        }
        coupons = couponTemp
        guard let date = early else { return nil}
        return date
    }

    @objc private func applicationDidBecomeActive() {
        self.handleExpiredCouponds()
    }
}

@available(iOS 10.0, *)
extension SIRLCouponService: CouponViewDelegate {

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

    public func dismissDefaultView() {
        self.couponButton.isOpen = false
        self.showCoupons()
    }

    //TODO Investigate if this is actually used
    public func loadCoupons() {
        if couponView.superview != nil {
            self.getAvailableCoupons { (coupons) in
                self.coupons = coupons
            }
        }
    }

    public func didDismissCoupon(id: Int) {
        self.addToIgnoreList(id: id)
        self.delegate?.didDismissCoupon?(id: id)
    }

    public func didClickEmailRegistration(at: Int) {
        self.delegate?.didClickEmailRegistration?(at: at)
    }

    public func loadCoupons(from coupons: [Coupon]) {
        self.couponView.loadCoupons(from: coupons)
    }

    public func hideEmailRegistrationButton(set: Bool) {
        self.couponView.hideEmailRegisterButton(set: set)
    }

    public func reloadCouponAt(index: Int) {
        self.couponView.reloadCouponAt(index: index)
    }

    public func reloadAllCoupons() {
        self.couponView.reloadAllCoupons()
    }

    public func notifyIfAvalible() {
        if self.couponView.areCouponsAvalible {
            DispatchQueue.main.async {
                self.couponButton.notifiyAvailbility()
            }
        }
    }

    public func didLoadCoupons() {
        DispatchQueue.main.async {
            if self.couponView.areCouponsAvalible {
                if self.couponButton.superview != nil {
                    self.couponButton.isHidden = false
                    self.couponButton.notifiyAvailbility()
                    if self.couponExpirationTimer == nil {
                        self.handleExpiredCouponds()
                    }
                  }
              } else {
                self.dismissDefaultView()
                self.couponButton.isHidden = true
                self.couponExpirationTimer = nil
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
