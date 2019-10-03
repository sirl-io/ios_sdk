//
//  DestinationMarker.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/20/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class DestinationMarker: UIView {

    private var markerImageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFit
        imgv.image = SirlBundleHelper.getResourceImage(name: "productmarker")
        imgv.translatesAutoresizingMaskIntoConstraints = false
        return imgv
    }()

    private var markerLabel: UILabel = {
        let ml = UILabel()
        ml.font = UIFont(name: ml.font.familyName, size: 9)
        ml.backgroundColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.9)
        ml.isHidden = true
        return ml
    }()

    private var button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var destLocation: CGPoint? {
        didSet {
            guard let location = destLocation else { return }
            self.frame.origin = CGPoint(x: location.x - self.makerWidth/2,
                                        y: location.y - self.markerHeight)
            self.markerLabel.sizeToFit()
            let markerLabelWidth = self.markerLabel.bounds.size.width
            self.markerLabel.frame.origin = CGPoint(x: location.x - markerLabelWidth/2,
                                                    y: location.y + 5)
        }
    }

    private var defaultMarkerSize: CGFloat = 30

    public var markerText: String? {
        didSet {
            if let text = markerText {
                self.markerLabel.text = text
                markerLabel.font = UIFont(name: markerLabel.font.familyName, size: 9/zoomScale)
                markerLabel.sizeToFit()
            }
        }
    }

    public var markerImage: UIImage? {
        get {
            return self.markerImageView.image
        }
        set {
            self.markerImageView.image = newValue
        }
    }

    public var markerSize: CGFloat? {
        didSet {
            guard let markerSize = markerSize else { return }
            self.frame.size = CGSize(width: markerSize,
                                     height: markerSize)
        }
    }

    var zoomScale: CGFloat = 1 {
        didSet {
            guard let size = markerSize else { return }
            let adjSize = size/zoomScale
            self.frame.size = CGSize(width: adjSize,
                                     height: adjSize)
            guard let location = destLocation else { return }
            self.frame.origin = CGPoint(x: location.x - self.makerWidth/2,
                                        y: location.y - self.markerHeight)
            markerLabel.font = UIFont(name: markerLabel.font.familyName, size: 9/zoomScale)
            markerLabel.sizeToFit()
            let markerLabelWidth = self.markerLabel.bounds.size.width
            markerLabel.frame.origin = CGPoint(x: location.x - markerLabelWidth/2,
                                               y: location.y + 5/zoomScale)
        }
    }

    public var makerWidth: CGFloat {
        return self.bounds.size.width
    }

    public var markerHeight: CGFloat {
        return self.bounds.size.height
    }

    func addMarker(to routeLayer: SirlRouteView, at location: CGPoint) {
        self.removeMarker()
        self.destLocation = location
        routeLayer.addSubview(self.markerLabel)
        routeLayer.addSubview(self)
    }

    func removeMarker() {
        if self.superview != nil {
            self.removeFromSuperview()
            self.markerLabel.isHidden = true
            self.markerLabel.removeFromSuperview()
        }
    }

    private func config() {
        self.markerSize = defaultMarkerSize
        self.addSubview(markerImageView)
        self.addSubview(button)
        self.button.addTarget(self, action: #selector(markerTouched), for: .touchUpInside)
        self.configLayout()
    }

    private func configLayout() {
        markerImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        markerImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        markerImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        markerImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }

    @objc func markerTouched() {
        self.markerLabel.isHidden = !self.markerLabel.isHidden
    }

}
