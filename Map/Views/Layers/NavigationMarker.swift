//
//  NavigationMarker.swift
//  SirlSDK
//
//  Created by Wei Cai on 1/21/19.
//  Copyright © 2019 SIRL Inc.. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 10.0, *)
open class NavigationMarker: CALayer {

    private let backgroundCircle = CAShapeLayer()
    private let innerCircle = CAShapeLayer()

    open var lightBlue = UIColor(red: 0.70, green: 0.89, blue: 1.00, alpha: 0.4)
    open var dakBlue = UIColor(red: 0.27, green: 0.70, blue: 0.94, alpha: 1.0)

    private var innerRingRadius: CGFloat!
    private var outerRingRadius: CGFloat!

    private var getInnerRingRadius: CGFloat {
        return innerRingRadius/zoomScale*2
    }

    var zoomScale: CGFloat = 1 {
        didSet {
            if zoomScale < 0.4 {
                drawInnerCircle()
            }
        }
    }

    public init(radius: CGFloat) {
        super.init()
        self.outerRingRadius = radius
        self.innerRingRadius = 3
        self.bounds.size = CGSize(width: radius*2, height: radius*2)
        self.isHidden = true
        drawShapes()
        addLayers()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    open override var bounds: CGRect {
        didSet {
            layoutIfNeeded()
        }
    }

    open override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.drawShapes()
        self.addLayers()
    }

    private func drawBackGroundCirlce() {
        let radius = self.bounds.size.width/2
        let arcCenter = CGPoint(x: radius, y: radius)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0 * .pi), clockwise: true)
        backgroundCircle.fillColor = lightBlue.cgColor
        backgroundCircle.path = circlePath.cgPath
    }

    private func drawInnerCircle() {
        let centerValue = self.bounds.size.width/2
        let arcCenter = CGPoint(x: centerValue, y: centerValue)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: getInnerRingRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0 * .pi), clockwise: true)
        innerCircle.fillColor = dakBlue.cgColor
        innerCircle.path = circlePath.cgPath
    }

    private func drawShapes() {
        drawBackGroundCirlce()
        drawInnerCircle()
    }

    private func addLayers() {
        self.addSublayer(backgroundCircle)
        self.addSublayer(innerCircle)
    }

    public func updateLocation(location: CGPoint) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = self.position
        animation.toValue = location
        animation.duration = 1.5
        if self.position.x != 0 && self.position.y != 0 {
            self.isHidden = false
        }
        self.position = location
        self.add(animation, forKey: "position")
    }

}
