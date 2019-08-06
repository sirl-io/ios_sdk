//
//  SirlMapObject.swift
//  SirlSDK
//
//  Created by Wei Cai on 6/7/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
import UIKit

public class SirlMapObject: Decodable {
    let mapID: Int!
    let x_max: Double!
    let y_max: Double!
    let x_min: Double!
    let y_min: Double!
    let mapPixelSize: CGSize!
    let tileSetURL: String!

    public init(mapID: Int, x_max: Double, y_max: Double, x_min: Double, y_min: Double, mapPixcelSize: CGSize, tileSet: String) {
        self.mapID = mapID
        self.x_max = x_max
        self.y_max = y_max
        self.x_min = x_min
        self.y_min = y_min

        self.mapPixelSize = mapPixcelSize
        self.tileSetURL = tileSet
    }

    enum SirlMapKeys: String, CodingKey {
        case sirlMap = "sirlMap"
    }

    enum MapParamsKey: String, CodingKey {
        case x_max = "xMaximum"
        case y_max = "yMaximum"
        case x_min = "xMinimum"
        case y_min = "yMinimum"
        case pixel_width = "pixelWidth"
        case pixel_height = "pixelHeight"
    }

    enum CodingKeys: String, CodingKey {
        case mlId = "mlId"
        case params = "mapParam"
        case layers = "tileSet"
        case mapBound = "mapBound"
    }

    public required convenience init(from decoder: Decoder) throws {
        let mapObject = try decoder.container(keyedBy: SirlMapKeys.self)
        let mapContainer = try mapObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .sirlMap)
        let mlId = try mapContainer.decode(Int.self, forKey: .mlId)
        let params = try mapContainer.nestedContainer(keyedBy: MapParamsKey.self, forKey: .params)
        let x_max = try params.decode(Double.self, forKey: .x_max)
        let y_max = try params.decode(Double.self, forKey: .y_max)
        let x_min = try params.decode(Double.self, forKey: .x_min)
        let y_min = try params.decode(Double.self, forKey: .y_min)
        let pxWidth = try params.decode(CGFloat.self, forKey: .pixel_width)
        let pxHeight = try params.decode(CGFloat.self, forKey: .pixel_height)
        let tileSet = try mapContainer.decode(String.self, forKey: .layers)

        self.init(mapID: mlId, x_max: x_max, y_max: y_max, x_min: x_min, y_min: y_min, mapPixcelSize: CGSize(width: pxWidth, height: pxHeight), tileSet: tileSet)
    }

}
