//
//  locateUserButtonLayer.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/9/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
open class LocateUserButtonLayer: CALayer {

    private let backgroundCircle = CAShapeLayer()
    private let backgroundHover = CAShapeLayer()
    private let innerDot = CAShapeLayer()
    private let outerShape = CAShapeLayer()

    open var color = UIColor(red: 0.964, green: 0.964, blue: 0.964, alpha: 0.828)
    open var color2 = UIColor(red: 1.00, green: 0.75, blue: 0.24, alpha: 1.0)
    open var color3 = UIColor(red: 0.98, green: 0.73, blue: 0.51, alpha: 0.3)

    //let
    override public init() {
        super.init()
        self.bounds = CGRect(x: 0, y: 0, width: 45, height: 45)
        customUIChanges()
        drawShapes()
        addLayers()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open var bounds: CGRect {
        didSet {
            layoutIfNeeded()
        }
    }
    override open func layoutSublayers() {
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

    override open func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.drawShapes()
        addLayers()
    }

    private func drawBackgroundCircle() {
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

    private func drawInnerDot() {
        let radius = self.bounds.size.width / 14
        let arcCenter = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.width / 2)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0 * .pi), clockwise: true)
        innerDot.fillColor = color2.cgColor
        innerDot.path = circlePath.cgPath
    }

    private func drawOuterShape() {
        let radius = self.bounds.size.width / 7
        let arcCenter = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.width / 2)
        let circlePath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2.0 * .pi), clockwise: true)
        let dashLen: CGFloat = radius/1.6

        let bezier1Path = UIBezierPath()
        bezier1Path.move(to: CGPoint(x: arcCenter.x, y: arcCenter.y+radius))
        bezier1Path.addLine(to: CGPoint(x: arcCenter.x, y: arcCenter.y+radius+dashLen))

        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: arcCenter.x, y: arcCenter.y-radius))
        bezier2Path.addLine(to: CGPoint(x: arcCenter.x, y: arcCenter.y-radius-dashLen))

        let bezier3Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: arcCenter.x-radius, y: arcCenter.y))
        bezier2Path.addLine(to: CGPoint(x: arcCenter.x-radius-dashLen, y: arcCenter.y))

        let bezier4Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: arcCenter.x+radius, y: arcCenter.y))
        bezier2Path.addLine(to: CGPoint(x: arcCenter.x+radius+dashLen, y: arcCenter.y))

        let finalPath = UIBezierPath()
        finalPath.append(circlePath)
        finalPath.append(bezier1Path)
        finalPath.append(bezier2Path)
        finalPath.append(bezier3Path)
        finalPath.append(bezier4Path)

        outerShape.fillColor = nil
        outerShape.strokeColor = color2.cgColor
        outerShape.lineWidth = 1.5
        outerShape.path = finalPath.cgPath

    }

    private func drawShapes() {
        backgroundCircle.removeFromSuperlayer()
        innerDot.removeFromSuperlayer()
        outerShape.removeFromSuperlayer()
        backgroundHover.removeFromSuperlayer()
        drawBackgroundCircle()
        drawOuterShape()
        drawInnerDot()
        drawBackgroundHover()
        addLayers()
    }

    private func addLayers() {
        self.addSublayer(backgroundCircle)
        self.addSublayer(backgroundHover)
        self.addSublayer(innerDot)
        self.addSublayer(outerShape)
    }

    open func addBackGroundHover() {
        self.backgroundHover.isHidden = false
    }

    open func removeBackGroundHover() {
        self.backgroundHover.isHidden = true
    }

    open func customUIChanges() {

    }

}
