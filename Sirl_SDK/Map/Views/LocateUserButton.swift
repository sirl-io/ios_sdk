//
//  LocateUserButton.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/18/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit

@IBDesignable
@available(iOS 10.0, *)
open class LocateUserButton: UIButton {
    open var buttonLayer = LocateUserButtonLayer()

    open override var isSelected: Bool {
        didSet {
            if isSelected {
                self.buttonLayer.addBackGroundHover()
            } else {
                self.buttonLayer.removeBackGroundHover()
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        buttonLayer.removeFromSuperlayer()
        self.layer.insertSublayer(buttonLayer, at: 0)
    }

}
