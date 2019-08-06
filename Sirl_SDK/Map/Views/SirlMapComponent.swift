//
//  SirlMapConponent.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/25/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import UIKit

#if canImport(SirlCoreSDK)
import SirlCoreSDK
#endif

@available(iOS 10.0, *)
class SirlmapComponent: UIScrollView, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    private var lastRotation: CGFloat = 0
    private var tapScaleMutiplier: Int = 2
    private var autoCenterTimer: Timer?
    private var autoCenter: Bool = false

    private lazy var rotaionGesture: UIRotationGestureRecognizer = {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        return rotationGesture
    }()

    private lazy var zoomingTap: UITapGestureRecognizer = {
        let zoomingTap = UITapGestureRecognizer(target: self, action: #selector(handleZoomingTap(_:)))
        zoomingTap.numberOfTapsRequired = 2
        return zoomingTap
    }()

    private let mapImageView: SirlMapTiledView = {
        let iv = SirlMapTiledView()
        iv.isUserInteractionEnabled = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private var mapImageSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.mapImageView.imageSize = mapImageSize
        }
    }

    private var routeView: SirlRouteView {
        return mapImageView.route
    }

    private var mapURL: URL? {
        didSet {
            self.mapImageView.url = mapURL
        }
    }

    var mapDelegate: SirlMapDelegate? {
        get {
            return self.routeView.delegate
        }
        set {
            self.routeView.delegate = newValue
        }
    }

    var dataSource: SirlCoreImpl {
        return routeView.dataSource
    }

    var currentLocation: sirlLocation {
        get {
            return routeView.currentLocation

        }
        set {
            routeView.currentLocation = newValue
            if self.autoCenter && self.routingMode {
                self.center(to: self.routeView.currentLocPX,
                            animated: true)
            }
        }
    }

    var currentDestination: sirlLocation {
        get {
            return routeView.currentDestination
        }
        set {
            routeView.currentDestination = newValue
        }
    }

    var destinationMarker: DestinationMarker? {
        return routeView.destinationMarker
    }

    var routingMode: Bool {
        get {
            return routeView.routingMode
        }
        set {
            routeView.routingMode = newValue
            if newValue {
                self.zoomInRoute()
                self.autoCenterTimer?.invalidate()
                self.autoCenter = false
                self.autoCenterTimer = Timer.scheduledTimer(withTimeInterval: 2,
                                                            repeats: false) { (_) in
                    self.autoCenter = true
                }
            } else {
                self.autoCenterTimer?.invalidate()
                self.autoCenter = false
            }
        }
    }

    @objc func handleRotationGesture(_ sender: UIRotationGestureRecognizer) {
        var  oldRotation = CGFloat()
        switch sender.state {
        case .began:
            sender.rotation = lastRotation
            oldRotation = sender.rotation
        case .changed:
            let newRotation = sender.rotation + oldRotation
            sender.view?.transform = CGAffineTransform(rotationAngle: newRotation)
        case .ended:
            lastRotation = sender.rotation
        default: break
        }
    }

    @objc func handleZoomingTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: mapImageView)
        self.zoom(to: location, animated: true)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.config()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let url = self.mapURL {
            mapImageConfig(newSuperview, mapImageURL: url)

        }
        self.addGestureRecognizer(rotaionGesture)
        self.addGestureRecognizer(zoomingTap)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showTiles(url: URL, size: CGSize) {
        self.mapImageSize = size
        self.mapURL = url
        self.mapImageConfig(self.superview, mapImageURL: self.mapURL!)
    }

    private func mapImageConfig(_ parentView: UIView?, mapImageURL: URL) {
        guard let parentView = parentView else {
            return
        }
        self.setMinScale(parentView: parentView, mapSize: self.mapImageSize)
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { (_) in
            self.setZoomScale(self.minimumZoomScale, animated: false)
        }
    }

    private func config() {
        self.delegate = self
        self.addSubview(mapImageView)
        mapImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mapImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mapImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mapImageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.maximumZoomScale = 1
        self.minimumZoomScale = 0.1
    }

    private func setMinScale(parentView: UIView?, mapSize: CGSize) {
        guard let mSuperView = parentView else { return }
        let boundSize = mSuperView.bounds.size
        let maxContentDimension = max(mapSize.width, mapSize.height)
        let minBoundDimenion = min(boundSize.width, boundSize.height)
        self.minimumZoomScale = minBoundDimenion/maxContentDimension
    }

    private func zoom(to point: CGPoint, animated: Bool) {
        let currentScale = self.zoomScale
        var destZoom = CGFloat(tapScaleMutiplier)*currentScale
        destZoom = destZoom > maximumZoomScale ? minimumZoomScale:destZoom
        let zoomRect = self.zoomRect(for: destZoom, withCenter: point)
        self.zoom(to: zoomRect, animated: animated)
    }

    private func center(to point: CGPoint, animated: Bool) {
        let targetZoom = self.zoomScale < 0.2 ? 0.2 : self.zoomScale
        let zoomRect = self.zoomRect(for: targetZoom, withCenter: point)
        if animated {
            UIView.animate(withDuration: 1.5, delay: 0, options: .beginFromCurrentState, animations: {
                self.zoom(to: zoomRect, animated: false)
            }, completion: nil)
        } else {
            self.zoom(to: zoomRect, animated: false)
        }
    }

    private func zoomInRoute() {
        guard let ratio = routeView.mapRatio,
            let superBounds = self.superview?.bounds else {return}
        let curLoc = currentLocation
        let destLoc = currentDestination
        if (curLoc.x != 0&&curLoc.y != 0)||(destLoc.x != 0 && destLoc.y != 0) {
            let midPoint = sirlLocation(x: (curLoc.x + destLoc.x)/2,
                                        y: (curLoc.y + destLoc.y)/2,
                                        z: 0)
            let midPointPx = routeView.convertToPXLocation(location: midPoint)
            let disX = abs(curLoc.x - destLoc.x)
            let disY = abs(curLoc.y - destLoc.y)
            let maxDis = disX > disY ? disX : disY
            let maxRatio = disX > disY ? ratio.width : ratio.height
            let maxDimension = disX > disY ? superBounds.width : superBounds.height
            let pxDis =  maxRatio * CGFloat(maxDis)
            var scale = maxDimension*0.55/pxDis
            scale = scale < 0.35 ? scale : 0.35
            UIView.animate(withDuration: 1, delay: 0, options: .beginFromCurrentState, animations: {
                self.zoom(to: self.zoomRect(for: scale, withCenter: midPointPx), animated: false)
            }, completion: nil)

        }
    }

    private func zoomRect(for scale: CGFloat, withCenter center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = self.bounds
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.mapImageView
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerMapImage(scrollView)
    }

    func centerMapImage(_ scrollView: UIScrollView) {
        guard let superView = self.superview else {return}
        let containerDim = superView.bounds.size
        let maxContainerDim = max(containerDim.width, containerDim.height)
        var extra = maxContainerDim * 3.5 * (self.zoomScale - self.minimumZoomScale)
        extra = extra > 0 ? extra : 0
        let constain = maxContainerDim/2.5
        extra = extra > constain ? constain : extra
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width)/CGFloat(2), 0.0) + extra
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height)/CGFloat(2), 0.0) + extra
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }

    func setMaxCord(xmax: CGFloat, ymax: CGFloat, xmin: CGFloat, ymin: CGFloat) {
        self.routeView.setMaxCord(xmax: xmax, ymax: ymax, xmin: xmin, ymin: ymin, mapSize: self.mapImageSize)
    }

    func resetRotation() {
        UIView.animate(withDuration: 0.5) {
            self.transform = CGAffineTransform(rotationAngle: 0)
            self.lastRotation = 0
        }
    }

    func resetDestination() {
        self.routeView.resetDestination()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.routeView.zoomScale = self.zoomScale
    }
}
