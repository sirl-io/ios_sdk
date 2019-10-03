//
//  couponButton.swift
//  Westside
//
//  Created by Wei Cai on 4/23/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
class CouponButton: UIView {
    var isOpen: Bool = false {
        didSet {
            if isOpen {
                cBtn.setTitle("Close", for: .normal)
            } else {
                cBtn.setTitle("Promotions", for: .normal)
            }
        }
    }

    private let cBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = sirlDarkBtnColor
        btn.layer.cornerRadius = 10

        if #available(iOS 11.0, *) {
            btn.layer.maskedCorners = [.layerMaxXMinYCorner]
        }

        btn.setTitle("Promotions", for: .normal)
        btn.titleLabel?.textAlignment = .center
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cText: UIView = {
        let view = UIView()
        view.backgroundColor = sirlLightBtnColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()

    private let cLabel: UILabel = {
        let txt = UILabel()
        txt.text = "Available"
        txt.font = UIFont(name: txt.font.familyName, size: 13)
        txt.textColor = .white
        txt.translatesAutoresizingMaskIntoConstraints = false
        txt.textAlignment = .center
        txt.clipsToBounds = true
        return txt
    }()

    private var textWidth: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            textWidth?.isActive = true
        }
    }

    var button: UIButton {
        return self.cBtn
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.conFigViews()
        self.cBtn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func conFigViews() {
        self.addSubview(cText)
        self.addSubview(cBtn)
        self.cText.addSubview(cLabel)
        cBtn.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        cBtn.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        cBtn.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cBtn.centerXAnchor.constraint(equalTo: cText.rightAnchor).isActive = true
        cText.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        cText.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.85).isActive = true
        cText.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.textWidth = cText.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
        cLabel.leftAnchor.constraint(equalTo: cText.leftAnchor).isActive = true
        cLabel.centerYAnchor.constraint(equalTo: cText.centerYAnchor).isActive = true
        cLabel.heightAnchor.constraint(equalTo: cText.heightAnchor).isActive = true
        cLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true

    }

    func notifiyAvailbility() {
        self.textWidth = cText.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.5)
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        }) { (complete) in
            if complete {
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
                    self.textWidth = self.cText.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.layoutIfNeeded()
                    })
                })
            }
        }
    }

    @objc private func buttonAction() {
        isOpen = !isOpen
    }

}
