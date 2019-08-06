//
//  routeView.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 4/26/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit
import os.log
#if canImport(SirlCoreSDK)
import SirlCoreSDK
#endif

@available(iOS 10.0, *)
class SirlRouteView: UIView {
    private var marker: CAShapeLayer?
    private var naviMarker: NavigationMarker?
    private var destination: DestinationMarker?
    private var currentHidingState: [Bool]?
    private var routing: CAShapeLayer?
    private var xMax: CGFloat?
    private var yMax: CGFloat?
    private var xMin: CGFloat?
    private var yMin: CGFloat?
    private var mapSize: CGSize?
    private let mLog = OSLog(subsystem: "com.sirl.map_manager", category: "Sirl_Map")
    private var routeTrackWindow = 12
    private var minDistFromPath: Double = 2
    private var hasArrived: Bool = false
    private let routingLineWidth: CGFloat = 35
    private let apiClient = SirlAPIClient.shared
    weak var delegate: SirlMapDelegate?
    let dataSource = SirlCoreImpl.shared

    private var cordRatio: CGSize? {
        if let xmax = self.xMax,
            let ymax=self.yMax,
            let xmin = self.xMin,
            let ymin=self.yMin,
            let mapsize = self.mapSize {
            var ratio = CGSize()
            ratio.width = (mapsize.width)/(xmax - xmin)
            ratio.height = (mapsize.height)/(ymax - ymin)
            return ratio
        }
        return nil
    }

    internal var mapRatio: CGSize? {
        return cordRatio
    }

    private var elog: SirlTripExecutionLogRecorder? {
        return SirlTripDataReporter.shared.executionLog
    }

    var currentLocation: sirlLocation = sirlLocation(x: 0, y: 0, z: 0) {
        didSet {
            currentPXLoaction = convertToPXLocation(location: currentLocation)
            if self.routingMode {
                if !updateNavigationRoutes() {
                    getRouteToDestination()
                }
            }
        }
    }

    var currentDestination: sirlLocation = sirlLocation(x: 0, y: 0, z: 0) {
        didSet {
            currentPXDestination = convertToPXLocation(location: currentDestination)
        }
    }

    var currentLocPX: CGPoint {
        return currentPXLoaction
    }

    private var currentPXLoaction: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            self.updateMarkerLoaction(currentPXLoaction)
        }
    }

    private var currentPXDestination: CGPoint = CGPoint(x: 0, y: 0) {
        didSet {
            if currentDestination.x == 0 && currentDestination.y == 0 {
                self.destination?.isHidden = true
            } else {
                self.updateDestination(currentPXDestination)

            }
        }
    }

    var zoomScale: CGFloat = 1 {
        didSet {
            destination?.zoomScale = zoomScale
            naviMarker?.zoomScale = zoomScale
            self.routing?.lineWidth = routingLineWidth * (1-zoomScale)
            let multiplier = Double(1-zoomScale)
            self.routing?.lineDashPattern = [5.0*multiplier, 100.0*multiplier] as [NSNumber]
        }
    }

    var destinationMarker: DestinationMarker? {
        return destination
    }

    var routingMode: Bool = false {
        didSet {
            if !routingMode || (currentLocation.x == 0 && currentLocation.y == 0) {
                self.removeRoutes()
                routeNodes = nil
            } else {
                getRouteToDestination()
            }
        }
    }

    private var routeNodes: [RouteNode]? {
        didSet {
            if routingMode {
                let firstNode = RouteNode(x: self.currentLocation.x, y: self.currentLocation.y)
                if var nodeSet = routeNodes, !nodeSet.isEmpty {
                    nodeSet[0] = firstNode
                    let location = self.currentDestination
                    nodeSet.append(RouteNode(x: location.x, y: location.y))
                    self.updateRoutes(routeNodes: nodeSet)
                    if nodeSet.count <= 4 {
                        self.hasArrived = true
                        var distance: Double = 0
                        if nodeSet.count > 1 {
                            for i in 0...nodeSet.count - 2 {
                                distance = distance + sqrt(
                                                        pow((nodeSet[i+1].location.x-nodeSet[i].location.x), 2) +
                                                        pow((nodeSet[i+1].location.y-nodeSet[i].location.y), 2)
                                                        )
                            }
                        }
                        self.delegate?.detinationApproached(distance: distance)
                    }
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for this class")
    }

    func setMaxCord(xmax: CGFloat, ymax: CGFloat, xmin: CGFloat, ymin: CGFloat, mapSize: CGSize) {
        self.xMax = xmax
        self.yMax = ymax
        self.xMin = xmin
        self.yMin = ymin
        self.mapSize = mapSize
    }

    internal func convertToPXLocation(location: sirlLocation) -> CGPoint {
        guard let xMin = self.xMin, let yMin = self.yMin else {
            return CGPoint(x: 0, y: 0)
        }
        var xRatio: Double = 100
        var yRatio: Double = 100
        var leftMargin: Double = 0
        var bottomMargin: Double = 0
        guard let cordRatio = self.cordRatio else {
            return CGPoint(x: 0, y: 0)
        }
        xRatio = Double(cordRatio.width)
        yRatio = Double(cordRatio.height)
        leftMargin = Double(xMin)
        bottomMargin = Double(yMin)
        let x = CGFloat((location.x - leftMargin) * xRatio)
        let _y = CGFloat((location.y - bottomMargin) * yRatio)
        let y = self.bounds.height - _y
        return CGPoint(x: x, y: y)
    }

    private func updateMarkerLoaction(_ mapLocation: CGPoint) {
        DispatchQueue.main.async {
            self.naviMarker?.updateLocation(location: mapLocation)
        }
    }

    private func updateDestination(_ mapLocation: CGPoint) {
        DispatchQueue.main.async {
            self.destination?.addMarker(to: self, at: mapLocation)
            if mapLocation.x == 0 && mapLocation.y == 0 {
                self.destination?.isHidden = true
            } else {
                self.destination?.isHidden = false
            }
        }
    }

    private func initLayers() {
        marker = CAShapeLayer()
        routing = CAShapeLayer()
        destination = DestinationMarker()
        configLayerComponents()
        naviMarker = NavigationMarker(radius: 150)
        self.layer.addSublayer(marker!)
        self.layer.addSublayer(naviMarker!)
    }

    private func configLayerComponents() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0),
                                      radius: CGFloat(10),
                                      startAngle: CGFloat(0),
                                      endAngle: CGFloat(Double.pi * 2),
                                      clockwise: true)
        marker?.path = circlePath.cgPath
        marker?.fillColor = UIColor(red: 0.502, green: 0.9137, blue: 0.9686, alpha: 0.8).cgColor
        routing?.strokeColor = UIColor(red: 0.27, green: 0.70, blue: 0.94, alpha: 1.0).cgColor
        marker?.strokeColor = UIColor.clear.cgColor
        routing?.fillColor = UIColor.clear.cgColor
        marker?.lineWidth = 1.0
        routing?.lineWidth = self.routingLineWidth
        routing?.lineJoin = CAShapeLayerLineJoin.round
        routing?.lineDashPattern = [5.0, 100.0]
        routing?.lineDashPhase = -80.0
        routing?.lineCap = CAShapeLayerLineCap.round
    }

    private func drawRoutes(routePoints: [CGPoint]) {
        self.routing?.removeFromSuperlayer()
        if routePoints.count > 1 {
            let route = UIBezierPath()
            route.move(to: routePoints[0])
            for i in 1 ... routePoints.count-1 {
                route.addLine(to: routePoints[i])
            }
            self.routing?.path = route.cgPath
            self.layer.insertSublayer(routing!, at: 0)
        }
    }

    func resetDestination() {
        if hasArrived {
            self.elog?.routeEvent(type: .complete)
        } else {
            self.elog?.routeEvent(type: .cancel)
        }
        hasArrived = false
        routingMode = false
        currentDestination = sirlLocation(x: 0, y: 0, z: 0)
    }

    private func removeRoutes() {
        routeVisible(false)
        routing?.removeFromSuperlayer()
    }

    private func routeVisible(_ show: Bool) {
        routing?.isHidden = !show
    }

}

// Routing functions

@available(iOS 10.0, *)
extension SirlRouteView {

    private func getRouteToDestination() {
        os_log("Requesting new route ", log: self.mLog, type: .debug)
        self.elog?.routeEvent(type: .reroute_auto)
        guard let mlId = self.dataSource.ML_ID
                else { return }
        apiClient.send(GetRouteToLocation(mlId: Int(mlId), destinations: [currentDestination], currentLocation: currentLocation)) { (res) in
            switch res {
            case .success(let result):
                //os_log("the route: %@", log:self.mLog,type:.debug,result.description)
                DispatchQueue.main.async {
                    self.routeNodes = nil
                    self.routeNodes = result
                    if self.routingMode {
                        self.routeVisible(true)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.routeVisible(false)
                }
                os_log("Unable to get route: %@", log: self.mLog, type: .error, error.localizedDescription)
            }
        }
    }

    private func updateNavigationRoutes() -> Bool {
        if var routeNodes = self.routeNodes, !routeNodes.isEmpty {
            let window = routeNodes.count > routeTrackWindow ? routeTrackWindow:routeNodes.count
            let subNodes = routeNodes[0..<window]
            let minDis = getMiniminDistance(location: self.currentLocation, routeNodes: Array(subNodes))
            if minDis.1 < minDistFromPath {
                routeNodes.removeSubrange(0 ..< minDis.0)
                self.routeNodes = routeNodes
                return true
            }
            return false
        } else {
            return false
        }
    }

    private func updateRoutes(routeNodes: [RouteNode]) {
        var pxRouteNode = [CGPoint]()
        for (i, node) in routeNodes.enumerated() {
            if i == 0 {
                continue
            }
            if i == 1 {
                let origin = routeNodes[0].location
                let currentNode = node.location
                let midPoint = sirlLocation(x: (origin.x + currentNode.x)/2,
                                            y: (origin.y + currentNode.y)/2,
                                            z: 0)
                let midPx = convertToPXLocation(location: midPoint)
                pxRouteNode.append(midPx)
            }
            let pxNode = convertToPXLocation(location: node.location)
            pxRouteNode.append(pxNode)
        }
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { (_) in
                self.drawRoutes(routePoints: pxRouteNode)
            })

        }
    }

    private func getMiniminDistance(location: sirlLocation, routeNodes: [RouteNode]) -> (Int, Double) {
        var minDis: Double = -1
        var minIndex: Int = -1
        for (index, element) in routeNodes.enumerated() {
            let nodeLoc = element.location
            let dist = sqrt(pow((nodeLoc.x-location.x), 2)+pow((nodeLoc.y-location.y), 2))
            if (minDis>0 && dist>minDis) {
                continue
            }
            minDis = dist
            minIndex = index
        }
        return (minIndex, minDis)
    }

}
