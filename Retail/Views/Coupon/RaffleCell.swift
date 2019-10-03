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
class RaffleCell: UICollectionViewCell {

    private enum RaffleState {
        case running
        case ended
        case announced
    }

    private var ttl: TimeInterval?
    private var expirationTime: Date?

    var coupon: Coupon? {
        didSet {
            guard let mCoupon = coupon else {return}

            self.raffleTitle = mCoupon.title
            self.raffleDetail = mCoupon.description
            self.raffleFinePrint = mCoupon.finePrint
            self.currentState = .running

            self.expireLabel.text = nil; //"Expires in \(ttl.stringFromTimeInterval())"
            //TODO announce and past Raffles
        }
    }

    private var activationTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private var currentState: RaffleState = .announced {
        didSet {
            switch currentState {
            case .running:
                expireLabel.isHidden = false
            case .ended:
                expireLabel.isHidden = true
                frontView.isHidden = false
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
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let backButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(15)
        btn.layer.cornerRadius = 15
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = sirlDarkBtnColor
        btn.setTitle("Back", for: .normal)
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

    private let raffleTitleView: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = "Raffle Title"
        lb.font = lb.font?.withSize(25)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let raffleDetailView: UITextView = {
        let lb = UITextView()
        lb.isEditable = false
        lb.textAlignment = .center
        lb.text = " "
        lb.font = lb.font?.withSize(15)
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private let finePrintView: UITextView = {
        let lb = UITextView()
        lb.isEditable = false
        lb.textAlignment = .center
        lb.text = "Fine Print ..."
        lb.font = lb.font?.withSize(15)
        lb.isScrollEnabled = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    private var raffleFinePrint: String? {
        didSet {
            if let input = raffleFinePrint {
                finePrintView.text = input
            }
        }
    }

    private var raffleTitle: String? {
        didSet {
            guard let raffleTitle = self.raffleTitle else {return}
            raffleTitleView.text = raffleTitle
        }
    }

    private var raffleDetail: String? {
        didSet {
            guard let raffleDetail = self.raffleDetail else {return}
            raffleDetailView.text = raffleDetail
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
        frontView.addSubview(raffleTitleView)
        frontView.addSubview(raffleDetailView)
        frontView.addSubview(expireLabel)
        frontView.addSubview(actionButton)
        backView.addSubview(finePrintView)
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
        raffleTitleView.topAnchor.constraint(equalTo: self.frontView.topAnchor, constant: 25).isActive = true
        raffleTitleView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        raffleTitleView.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
        raffleTitleView.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
        raffleDetailView.topAnchor.constraint(equalTo: self.raffleTitleView.bottomAnchor, constant: 5).isActive = true
        //        raffleDetailView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        raffleDetailView.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
        raffleDetailView.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true

        if(self.expireLabel.text != nil) {
            expireLabel.topAnchor.constraint(equalTo: self.raffleDetailView.bottomAnchor).isActive = true
            expireLabel.bottomAnchor.constraint(equalTo: self.actionButton.topAnchor).isActive = true
            expireLabel.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, constant: -40).isActive = true
            expireLabel.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
        } else {
            actionButton.topAnchor.constraint(equalTo: self.raffleDetailView.bottomAnchor).isActive = true
        }

        actionButton.bottomAnchor.constraint(equalTo: self.frontView.bottomAnchor, constant: -15).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        actionButton.widthAnchor.constraint(equalTo: self.frontView.widthAnchor, multiplier: 0.55).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: self.frontView.centerXAnchor).isActive = true
    }

    private func configBack() {
        backView.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
        backView.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true
        finePrintView.topAnchor.constraint(equalTo: self.backView.topAnchor, constant: 15).isActive = true
        finePrintView.widthAnchor.constraint(equalTo: self.backView.widthAnchor, multiplier: 0.9).isActive = true
        finePrintView.centerXAnchor.constraint(equalTo: self.backView.centerXAnchor).isActive = true
        backButton.topAnchor.constraint(equalTo: self.finePrintView.bottomAnchor, constant: 15).isActive = true
        backButton.widthAnchor.constraint(equalTo: self.backView.widthAnchor, multiplier: 0.25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.bottomAnchor.constraint(equalTo: self.backView.bottomAnchor, constant: -15).isActive = true
        backButton.centerXAnchor.constraint(equalTo: self.backView.centerXAnchor).isActive = true
    }

    @objc private func showFinePrint() {
        frontView.isHidden = true
        backView.isHidden = false
        UIView.transition(with: self.container, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }

    @objc private func buttonAction() {
        switch currentState {
        case .running: fallthrough
        case .announced: fallthrough
        case .ended:
            if SirlCoreImpl.shared.inActiveRegion {
                showFinePrint()
            } else {
                let alert = SubviewAlert.presentAlert(target: self,
                                                      message: "Please visit the store to be entered into the raffle.")
                alert.alertButton.setTitle("Retry", for: .normal)
                alert.alertButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            }
            break
        }
    }

    @objc private func backAction() {
        frontView.isHidden = false
        backView.isHidden = true
        UIView.transition(with: self.container, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }

    @objc private func handleApplicationReActive() {
    }

    private func setActionButton() {
        switch currentState {
        case .running: fallthrough
        case .ended: fallthrough
        case .announced:
            actionButton.backgroundColor = sirlDarkBtnColor
            actionButton.setTitle("View Fine Print", for: .normal)
        }
    }

    private func startTimer() {
        if expirationTime == nil {
            guard let ttl = ttl else {return}
            expirationTime = Date().addingTimeInterval(ttl)
        }
    }
}
