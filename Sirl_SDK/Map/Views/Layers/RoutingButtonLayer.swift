//
//  routingButtonLayer.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/23/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit
#if canImport(SirlCoreSDK)
import SirlCoreSDK
#endif

@available(iOS 10.0, *)
open class RoutingButtonLayer: CALayer {

    private let backgroundCircle = CAShapeLayer()
    private let backgroundHover = CAShapeLayer()
    private let shapeLayer = CALayer()

    open var color = UIColor(red: 0.964, green: 0.964, blue: 0.964, alpha: 0.828)
    open var color2 = UIColor(red: 1.00, green: 0.75, blue: 0.24, alpha: 1.0)
    open var color3 = UIColor(red: 0.98, green: 0.73, blue: 0.51, alpha: 0.3)

    public override init() {
        super.init()
        self.bounds = CGRect(x: 0, y: 0, width: 45, height: 45)
        drawShapes()
        addLayers()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override var bounds: CGRect {
        didSet {
            layoutIfNeeded()
        }
    }

    open override func layoutSublayers() {
        super.layoutSublayers()
        guard let superLayer = self.superlayer else {
            return
        }
        let superSize = superLayer.bounds.size
        let minSide = superSize.width > superSize.height ? superSize.height : superSize.width
        self.bounds.size = CGSize(width: minSide, height: minSide)
        var xOffset = (superSize.width - self.bounds.size.width)/2
        var yOffset = (superSize.height - self.bounds.size.width)/2
        xOffset = xOffset > 0 ? xOffset : 0
        yOffset = yOffset > 0 ? yOffset : 0
        self.frame.origin = CGPoint(x: xOffset, y: yOffset)
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
        backgroundCircle.fillColor = color.cgColor
        backgroundCircle.path = circlePath.cgPath
        backgroundCircle.lineWidth = 0.2
        backgroundCircle.strokeColor = color2.cgColor
    }

    private func drawBackgroundHover() {
        let radius = self.bounds.size.width/2
        let arcCenter = CGPoint(x: radius, y: radius)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0 * .pi), clockwise: true)
        backgroundHover.fillColor = color3.cgColor
        backgroundHover.path = circlePath.cgPath
        backgroundHover.isHidden = true
    }

    private func drawRouteShape() {
        let shapeImage = SirlBundleHelper.getResourceImage(name: "route")?.cgImage
        let shapeLayerSize = CGFloat(sqrt(2))*self.bounds.size.width/2
        let shapeOrginX = (self.bounds.width - shapeLayerSize)/2
        let shapeOrginY = (self.bounds.height - shapeLayerSize)/2
        shapeLayer.frame = CGRect(x: shapeOrginX, y: shapeOrginY, width: shapeLayerSize, height: shapeLayerSize)
        shapeLayer.contents = shapeImage
    }

    private func drawShapes() {
        drawBackGroundCirlce()
        drawBackgroundHover()
        drawRouteShape()
    }

    private func addLayers() {
        self.addSublayer(backgroundCircle)
        self.addSublayer(backgroundHover)
        self.addSublayer(shapeLayer)
    }

    open func addBackGroundHover() {
        self.backgroundHover.isHidden = false
    }

    open func removeBackGroundHover() {
        self.backgroundHover.isHidden = true
    }

}
