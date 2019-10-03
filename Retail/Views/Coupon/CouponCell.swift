//
//  CouponCell.swift
//  Westside
//
//  Created by Wei Cai on 4/24/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
class CouponCell: UICollectionViewCell {

    private enum CouponState {
        case notActivated
        case isActivated
        case isBeingActivated
        case isExpired
    }

    private var ttl: TimeInterval?
    private var expirationTime: Date?

    var coupon: Coupon? {
        didSet {
            guard let mCoupon = coupon else {return}
            self.couponTitle = mCoupon.title
            self.couponDetail = mCoupon.description
            guard let code = mCoupon.code,
                  let expiration = mCoupon.expiration else {
                    self.currentState = .notActivated
                    if let ttl = mCoupon.ttlSeconds {
                        self.ttl = TimeInterval(ttl)
                    }
                    return
            }
            self.couponCode = code
            let timeRemain = -Date().timeIntervalSince(expiration)
            self.ttl = timeRemain > 0 ? timeRemain : 0
            self.currentState = .isActivated
        }
    }

    private var activationTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var currentState: CouponState = .notActivated {
        didSet {
            switch currentState {
            case .isActivated:
                startTimer()
                expireLabel.isHidden = false
            case .isExpired:
                expireLabel.isHidden = true
                frontView.isHidden = false
                backView.isHidden = true
            default:
                break
            }
            setActionButton()
        }
    }

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let frontView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let actionButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(15)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let backButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let expireLabel: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.textAlignment = .center
        lb.font = lb.font.withSize(10)
        lb.textColor = UIColor(red: 0.76, green: 0.45, blue: 0.07, alpha: 1.0)
        return lb
    }()

    private let couponTitleView: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "Coupon Title"
        lb.font = lb.font?.withSize(25)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let couponDetailView: UITextView = {
        let lb = UITextView()
        lb.isEditable = false
        lb.textAlignment = .center
        lb.text = " "
        lb.font = lb.font?.withSize(15)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let barCodeView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleToFill
        imv.translatesAutoresizingMaskIntoConstraints = false
        return imv
    }()

    private let couponCodeView: UILabel = {
        let lb = UILabel()
        lb.contentMode = .scaleToFill
        lb.textAlignment = .center
        lb.text = "coupon code"
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private var couponCode: String? {
        didSet {
            if let input = couponCode {
                couponCodeView.text = input
                barCodeView.image = generateBarcode(from: input)
            }
        }
    }

    private var couponTitle: String? {
        didSet {
            guard let couponTitle = self.couponTitle else {return}
            couponTitleView.text = couponTitle
        }
    }

    private var couponDetail: String? {
        didSet {
            guard let couponDetail = self.couponDetail else {return}
            couponDetailView.text = couponDetail
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
        actionButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        NotificationCenter.default
                          .addObserver(self, selector: #selector(handleApplicationReActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default
            .removeObserver(self,
                            name: UIApplication.didBecomeActiveNotification,
                            object: nil)
    }

    private func configView() {
        self.addSubview(container)
        container.addSubview(frontView)
        container.addSubview(backView)
        frontView.addSubview(couponTitleView)
        frontView.addSubview(couponDetailView)
        frontView.addSubview(expireLabel)
        frontView.addSubview(actionButton)
        backView.addSubview(barCodeView)
        backView.addSubview(couponCodeView)
        backView.addSubview(backButton)
        configContainer()
        configFront()
        configBack()
        setActionButton()
    }

    private func configContainer() {
        container.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        container.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -6).isActive = true
        container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 6).isActive = true
        container.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
    }

    private func configFront() {
        frontView.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
        frontView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
        frontView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
        frontView.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
        couponTitleView.topAnchor.constraint(equalTo: self.frontView.topAnchor, constant: 25).isActive = true
        couponTitleView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        couponTitleView.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
        couponTitleView.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
        couponDetailView.topAnchor.constraint(equalTo: self.couponTitleView.bottomAnchor, constant: 5).isActive = true
        couponDetailView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        couponDetailView.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
        couponDetailView.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
        expireLabel.topAnchor.constraint(equalTo: self.couponDetailView.bottomAnchor).isActive = true
        expireLabel.bottomAnchor.constraint(equalTo: self.actionButton.topAnchor).isActive = true
        expireLabel.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
        expireLabel.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: self.frontView.bottomAnchor, constant: -30).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        actionButton.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, multiplier: 0.55).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
    }

    private func configBack() {
        backView.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
        barCodeView.topAnchor.constraint(equalTo: self.backView.topAnchor, constant: 10).isActive = true
        barCodeView.widthAnchor.constraint(equalTo: self.backView.widthAnchor, multiplier: 0.75).isActive = true
        barCodeView.heightAnchor.constraint(equalTo: self.backView.heightAnchor, multiplier: 0.65).isActive = true
        barCodeView.centerXAnchor.constraint(equalTo: self.backView.centerXAnchor).isActive = true
        couponCodeView.topAnchor.constraint(equalTo: self.barCodeView.bottomAnchor, constant: 1).isActive = true
        couponCodeView.widthAnchor.constraint(equalTo: self.barCodeView.widthAnchor).isActive = true
        couponCodeView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        couponCodeView.centerXAnchor.constraint(equalTo: self.barCodeView.centerXAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: self.backView.topAnchor).isActive = true
        backButton.trailingAnchor.constraint(equalTo: self.backView.trailingAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: self.backView.leadingAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.backView.bottomAnchor).isActive = true
    }

    private func showBarCode() {
        frontView.isHidden = true
        backView.isHidden = false
        UIView.transition(with: self.container, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }

    @objc private func buttonAction() {
        switch currentState {
        case .isActivated:
            if couponCode != nil {
                showBarCode()
            }
        case .notActivated:
            if SirlCoreImpl.shared.inActiveRegion {
                let alert = SubviewAlert.presentAlert(target: self,
                                                      message: "The coupon code will expire in \(String(describing: ttl?.hourStringFromTimeInterval())) after activation.\nDo you want to continue?")
                alert.alertButton.setTitle("Continue", for: .normal)
                alert.alertButton.addTarget(self, action: #selector(activateCoupon), for: .touchUpInside)
            } else {
                let alert = SubviewAlert.presentAlert(target: self,
                                                      message: "Please visit the store to redeem the coupon")
                alert.alertButton.setTitle("Retry", for: .normal)
                alert.alertButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            }
        default:
            break
        }

    }

    @objc private func backAction() {
        frontView.isHidden = false
        backView.isHidden = true
        UIView.transition(with: self.container, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }

    private func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            if let output = filter.outputImage {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    private func resetTimer() {
        expireLabel.isHidden = true
        guard let expirationDate = self.expirationTime else {
            activationTimer = nil
            return
        }
        expireLabel.isHidden = false
        activationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            let ttl = -Date().timeIntervalSince(expirationDate)
            if ttl <= 0 {
                self.currentState = .isExpired
            } else {
                self.expireLabel.text = "Expires in \(ttl.stringFromTimeInterval())"
            }

        })
    }

   @objc private func handleApplicationReActive() {
        resetTimer()
    }

    @objc private func activateCoupon() {
        guard let coupon = self.coupon else {return}
        self.currentState = .isBeingActivated
        SIRLCouponService.shared.claimCoupons(with: coupon) { (mCoupon) in
            DispatchQueue.main.async {
                guard let coupon = mCoupon else { return }
                self.coupon = coupon
                if self.currentState == .isActivated {
                    self.showBarCode()
                }
            }

        }
    }

    private func setActionButton() {
        switch currentState {
        case .notActivated:
            actionButton.backgroundColor = sirlDarkBtnColor
            actionButton.setTitle("Redeem", for: .normal)
        case .isActivated:
            actionButton.backgroundColor = sirlDarkBtnColor
            actionButton.setTitle("Show Coupon Code", for: .normal)
        case .isExpired:
            actionButton.backgroundColor = .gray
            actionButton.setTitle("Expired", for: .disabled)
            actionButton.isEnabled = false
        case .isBeingActivated:
            actionButton.backgroundColor = sirlDarkBtnColor
            actionButton.setTitle("Activating", for: .normal)
        }

    }

    private func startTimer() {
        if expirationTime == nil {
            guard let ttl = ttl else {return}
            expirationTime = Date().addingTimeInterval(ttl)
            resetTimer()
        }
    }

}

@available(iOS 10.0, *)
extension TimeInterval {

    func stringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }

    func hourStringFromTimeInterval() -> String {
        let time = NSInteger(self)
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        var hourString = ""
        var andString = ""
        if hours > 0 {
            hourString = "\(hours) hours"
            andString = " and "
        }
        if minutes > 0 {
            hourString = hourString + andString + "\(minutes) minutes"
        }
        return hourString
    }
}
