//
//  CouponRedeemAlert.swift
//  Westside
//
//  Created by Wei Cai on 4/25/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

class SubviewAlert: UIView {

    static func presentAlert(target: UIView, message: String) -> SubviewAlert {
        let alert = SubviewAlert()
        alert.frame = target.bounds
        alert.alertMessage = message
        target.addSubview(alert)
        return alert
    }

    private let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        }()

    let alertButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Confirm", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = sirlDarkBtnColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.79, green: 0.27, blue: 0.27, alpha: 1.0)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    let messageView: VerticallyCenteredTextView = {
        let tv = VerticallyCenteredTextView()
        tv.isEditable = false
        tv.textAlignment = .center
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    var alertMessage: String? {
        didSet {
            messageView.text = alertMessage
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.6)
        self.configView()
        self.alertButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configView() {
        self.addSubview(alertView)
        alertView.addSubview(messageView)
        alertView.addSubview(alertButton)
        alertView.addSubview(cancelButton)
        alertView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        alertView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8).isActive = true
        alertView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        alertView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        messageView.widthAnchor.constraint(equalTo: alertView.widthAnchor, constant: -40).isActive = true
        messageView.bottomAnchor.constraint(equalTo: alertButton.topAnchor, constant: -10).isActive = true
        messageView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 10).isActive = true
        messageView.centerXAnchor.constraint(equalTo: alertView.centerXAnchor).isActive = true
        alertButton.widthAnchor.constraint(equalTo: alertView.widthAnchor, multiplier: 0.5).isActive = true
        alertButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor).isActive = true
        alertButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        alertButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalTo: alertView.widthAnchor, multiplier: 0.5).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor).isActive = true
    }

    @objc private func dismiss() {
        self.removeFromSuperview()
    }

    class VerticallyCenteredTextView: UITextView {
        override var contentSize: CGSize {
            didSet {
                var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
                topCorrection = max(0, topCorrection)
                contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
            }
        }
    }
}
