//
//  RouteButton.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/23/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit

@IBDesignable
@available(iOS 10.0, *)
open class RouteButton: UIButton {
    let buttonLayer = RoutingButtonLayer()

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
        self.layer.insertSublayer(buttonLayer, at: 0)
    }

}
