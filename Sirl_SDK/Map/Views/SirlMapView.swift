//
//  SirlMapView.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/25/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import UIKit
import os.log

@available(iOS 10.0, *)
public protocol SirlMapDelegate: class {
    func detinationApproached(distance: Double)
}
@available(iOS 10.0, *)
public extension SirlMapDelegate {
    func detinationApproached(distance: Double) {}
}

@IBDesignable
@available(iOS 10.0, *)
open class SirlMapView: UIView {
    private var hasLayoutContainer: Bool = false
    private let mLog = OSLog(subsystem: "com.sirl.map_manager", category: "Sirl_Map")
    private let apiClient = SirlAPIClient.shared
    private var ttl: TimeInterval = 24*60*60*7

    public var delegate: SirlMapDelegate? {
        get {
            return mapComponent.mapDelegate
        }set {
            mapComponent.mapDelegate = newValue
        }
    }

    public var cacheTTL: TimeInterval {
        get {
            return self.ttl
        }
        set {
            self.ttl = newValue
        }
    }

    private var dataSource: SirlCoreImpl {
        return mapComponent.dataSource
    }

    private var mapLoaded: Bool = false {
        didSet {
            if mapLoaded {
                self.navigationModeButton.isHidden = false
            } else {
                self.navigationModeButton.isHidden = true
            }
        }
    }

    let mapComponent: SirlmapComponent = {
        let mc = SirlmapComponent()
        mc.translatesAutoresizingMaskIntoConstraints = false
        return mc
    }()

    open var navigationModeButton: LocateUserButton = {
        let lb = LocateUserButton()
        lb.isHidden = true
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    open var routingButton: RouteButton = {
        let rb = RouteButton()
        rb.isHidden = true
        rb.translatesAutoresizingMaskIntoConstraints = false
        return rb
    }()

    public var desinationMarker: DestinationMarker? {
        return mapComponent.destinationMarker
    }

    public var routingMode: Bool {
        get {
            return mapComponent.routingMode
        }set {
            mapComponent.routingMode = newValue
            self.routingButton.isSelected = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()

    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }

    override open func layoutSubviews() {
        layoutMapComponent()
        if mapLoaded { return }
        guard let mlid = self.mapComponent.dataSource.ML_ID else {return}
        loadMap(mapID: Int(mlid))
    }

    private func config() {
        self.clipsToBounds = true
        self.mapComponent.dataSource.sirlMapAdapter = self
        self.navigationModeButton.addTarget(self, action: #selector(navigationButtonAction(sender:)), for: .touchUpInside )
        self.routingButton.addTarget(self, action: #selector(routingButtonAction(sender:)), for: .touchUpInside )
    }

    private func layoutButtons() {
        self.addSubview(routingButton)
        self.addSubview(navigationModeButton)
        self.navigationModeButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        self.navigationModeButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        self.navigationModeButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -15).isActive = true
        self.navigationModeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        self.routingButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        self.routingButton.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        self.routingButton.rightAnchor.constraint(equalTo: self.navigationModeButton.leftAnchor, constant: -15).isActive = true
        self.routingButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true

    }

    private func layoutMap() {
        let mSize = self.bounds.size
        let containerDimension = sqrt(pow(mSize.height, 2)+pow(mSize.width, 2))
        self.addSubview(mapComponent)
        self.mapComponent.widthAnchor.constraint(equalToConstant: containerDimension).isActive = true
        self.mapComponent.heightAnchor.constraint(equalToConstant: containerDimension).isActive = true
        self.mapComponent.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.mapComponent.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    private func layoutMapComponent() {
        if hasLayoutContainer {
            return
        }
        self.layoutMap()
        self.layoutButtons()
        self.hasLayoutContainer = true
    }

    private func loadMapFromCache(mapID: String) -> Bool {
        let fileManager = FileManager.default
        let mCache = CacheManager.shared
        do {
            let mapDirPath = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("SirlMap", isDirectory: true)
                .appendingPathComponent(mapID, isDirectory: true)
                .appendingPathComponent("tiles", isDirectory: true)
            let imageInfoFile = mapDirPath.deletingLastPathComponent()
                .appendingPathComponent("imageInfo.plist", isDirectory: false)
            if fileManager.fileExists(atPath: mapDirPath.path)&&fileManager.fileExists(atPath: imageInfoFile.path) {
                let imageInfo = NSDictionary(contentsOfFile: imageInfoFile.path)!
                if let timeCreated = imageInfo["timeCreated"] as? Date {
                    let timeInterval = NSDate().timeIntervalSince(timeCreated)
                    if timeInterval > ttl {
                        mCache.clearMapCache(mapID: mapID)
                        return false
                    }
                }
                if let imageWidth = imageInfo["width"] as? CGFloat,
                    let imageHeight = imageInfo["height"] as? CGFloat,
                    let xMax = imageInfo["xMax"] as? CGFloat,
                    let yMax = imageInfo["yMax"] as? CGFloat,
                    let xMin = imageInfo["xMin"] as? CGFloat,
                    let yMin = imageInfo["yMin"] as? CGFloat {
                    DispatchQueue.main.async {
                        self.mapComponent.showTiles(url: mapDirPath, size: CGSize(width: imageWidth, height: imageHeight))
                        self.mapComponent.setMaxCord(xmax: xMax, ymax: yMax, xmin: xMin, ymin: yMin)
                        self.mapLoaded = true
                    }
                }

            } else {
                return false
            }
        } catch (let error) {
            fatalError("Error finding map cache path. \(error)")
        }
        return true
    }

    private func loadMap(mapID: Int) {
        guard !loadMapFromCache(mapID: "\(mapID)")else {
            return
        }
        os_log("Get map info ...", log: self.mLog, type: .debug)
        apiClient.send(GetLocationMap(mapId: mapID)) { (res) in
            switch res {
            case .success(let result):
                let myDL = SirlMapDownLoader()
                myDL.download(url: result.tileSetURL, ML_ID: String(mapID), completion: { (localMapURL) in
                    let dic: [String: Any] = ["mlId": result.mapID,
                                              "xMax": result.x_max,
                                              "yMax": result.y_max,
                                              "xMin": result.x_min,
                                              "yMin": result.y_min,
                                              "width": result.mapPixelSize.width,
                                              "height": result.mapPixelSize.height,
                                              "timeCreated": Date()]
                    let plistDic = NSDictionary(dictionary: dic)
                    let infoFile = localMapURL.appendingPathComponent("imageInfo.plist", isDirectory: false)
                    _ = plistDic.write(toFile: infoFile.path, atomically: true)
                    _ = self.loadMapFromCache(mapID: "\(mapID)")

                })
            case .failure(let error):
                os_log("Touble downloading map: %@", log: self.mLog, type: .error, error.localizedDescription)
            }
        }
    }

    public func reload() {
        if let locationID = self.dataSource.ML_ID {
            loadMap(mapID: Int(locationID))
        }
    }

    @ objc private func navigationButtonAction(sender: LocateUserButton) {
       self.mapComponent.resetRotation()
    }

    @ objc private func routingButtonAction(sender: RouteButton) {
        routingMode = !routingMode
    }
}

// Navigation Functions

@available(iOS 10.0, *)
extension SirlMapView {//:SirlMapComponentDelegate {

    open func updateMarkerLocation(location: sirlLocation) {
        if(mapLoaded) {
            mapComponent.currentLocation = location
        }
    }

    open func updateDestination(location: sirlLocation, destinationDescription: String? = nil) {
        if(mapLoaded) {
            mapComponent.currentDestination = location
            mapComponent.destinationMarker?.markerText = destinationDescription
            routingButton.isHidden = false
        }
    }

    open func resetDestination() {
        mapComponent.resetDestination()
        routingButton.isSelected = false
        routingButton.isHidden = true
    }

}

// Connetion to Sirl Core

@available(iOS 10.0, *)
extension SirlMapView: SirlCoreMapDelegate {

    public func didGetNewPosition(_ position: sirlLocation) {
        self.updateMarkerLocation(location: position)
    }

    public func didDetectMapLocation(mlId: UInt32) {
        self.loadMap(mapID: Int(mlId))
    }
}
