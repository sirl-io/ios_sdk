//
//  SirlMapTileView.swift
//  SirlSDK
//
//  Created by Wei Cai on 3/25/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import UIKit
import os.log

@available(iOS 10.0, *)
class SirlMapTiledView: UIView {

    private let mLog = OSLog(subsystem: "com.sirl.Map_Tiled_View", category: "Sirl_Map")
    private let mRouteView: SirlRouteView = {
        let rv = SirlRouteView()
        return rv
    }()

    var url: URL? {
        didSet {
            setNeedsDisplay()
        }
    }

    private var viewBounds: CGRect!

    private var tiledLayer: CATiledLayer!

    var route: SirlRouteView {
        return mRouteView
    }

    var imageSize: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        return imageSize
    }

    override class var layerClass: AnyClass {
        return CATiledLayer.self
    }

    override var contentScaleFactor: CGFloat {
        didSet {
            super.contentScaleFactor = 1
        }
    }

   override init(frame: CGRect) {
        super.init(frame: frame)
        self.tiledLayer = self.layer as? CATiledLayer
        self.backgroundColor = UIColor.clear
        self.tiledLayer.levelsOfDetail = 4
        self.viewBounds = self.bounds
        self.addSubview(mRouteView)
    }

    override func layoutSubviews() {
        self.viewBounds = self.bounds
        self.mRouteView.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented for this class")
    }

    override func draw(_ rect: CGRect) {
        if url == nil {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        let xScale: CGFloat = context.ctm.a
        let yScale: CGFloat = context.ctm.d
        var tileSize: CGSize! = self.tiledLayer.tileSize
        tileSize.width /= xScale
        tileSize.height /= -yScale
        let firstCol = Int(floor(rect.minX / tileSize.width))
        let lastCol = Int(floor((rect.maxX-1) / tileSize.width))
        let firstRow = Int(floor(rect.minY / tileSize.height))
        let lastRow = Int(floor((rect.maxY-1) / tileSize.height))
        for row in firstRow ... lastRow {
            for col in firstCol...lastCol {
                guard let tile = self.getTileFor(scale: xScale, row: row, col: col) else {
                    os_log("Tiled Image not found", log: self.mLog, type: .debug)
                    return
                }
                let xpos = tileSize.width * CGFloat(col)
                let ypos = tileSize.height * CGFloat(row)
                var tileRect = CGRect(x: xpos, y: ypos, width: tileSize.width, height: tileSize.height)
                tileRect = viewBounds.intersection(tileRect)
                tile.draw(in: tileRect)
            }
        }
    }

    private func getTileFor(scale: CGFloat, row: Int, col: Int) -> UIImage? {
        guard let url = self.url else {return nil}
        let scale = scale < 1.0 ? Int(1/CGFloat(Int(1/scale))*1000) : Int(scale*1000)
        let tileName = "\(scale)/tile-\(col)-\(row).png"
        let filepath = url.appendingPathComponent(tileName).path
        return UIImage(contentsOfFile: filepath)
    }

}
