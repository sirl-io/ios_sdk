//
//  TileStruct.swift
//  tiledImageMaker
//
//  Created by Seyed Samad Gholamzadeh on 2/3/18.
//  Copyright © 2018 Seyed Samad Gholamzadeh. All rights reserved.
//

import Foundation
import UIKit
import os.log

@available(iOS 10.0, *)
public struct TileManager {
    private let mLog = OSLog(subsystem: "com.sirl.map_tile_manager", category: "Sirl_Map")
    private enum TileMakerError: Error {
        case destinationContextFailedToMakeImage
        case inputImageNotFound
        case failedToCreateTheOutputBitmapContext
    }

    private let destImageSizeMB: Int // The resulting image will be (x)MB of uncompressed image data.
    private let sourceImageTileSizeMB: Int // The tile size will be (x)MB of uncompressed image data.
    private let tileSize: Int

    /* Constants for all other iOS devices are left to be defined by the developer.
     The purpose of this sample is to illustrate that device specific constants can
     and should be created by you the developer, versus iterating a complete list. */

    private let bytesPerMB: Int = 1048576
    private let bytesPerPixel: Int = 4

    private var pixelsPerMB: Int {
        return ( bytesPerMB / bytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.
    }

    private var destTotalPixels: Int {
        return destImageSizeMB * pixelsPerMB
    }

    private var tileTotalPixels: Int {
        return sourceImageTileSizeMB * pixelsPerMB
    }

    private let destSeamOverlap: Float = 2 // the numbers of pixels to overlap the seams where tiles meet.

    private let fileManager = FileManager.default

    /**
     A Boolean value that controls whether the sourceimage will be down sized or not.

     If the value of this property is true, the source image be down sized.
     The default value is true.
     */
    public  var downSizeSourceImage: Bool = true

    /**
     Initializes and returns a newly struct with the specified parameters.
     The methods of this struct uses to manage tiles.

     - Parameters:
     - destImageSize:
     The maximum size of destination image in MB when uncomperessed in memory.
     The value should be smaller than uncompressed size of source image in memory.
     If you set a value bigger than the original size of source image for this parameter,
     the original size of image uses for tiling. To know how is the size of source image
     when uncomperessed in memory use **totalMBForImage(in url: URL)** method.
     The default value of this parameter is 60.

     - sourceImageDownSizingTileSize:
     The size of tiles for down sizing the source image in MB,  if you want to down size of source image.
     This argument is  because of that, we do not want to down size whole of source image instantly,
     because that needs to load whole of source image in memory and it occupies a lot of memory.
     Instead we shrink the source image to some small tiles and down size these tiles in order.
     You should be careful about setting value of this parameter. Setting very small value causes high cpu
     usage and setting very large value causes high memory usage. The default value of this parameter is 20.

     - tileSize:
     The size of each tile used for CATiledLayer. The default value is 256.

     - Returns:
     An initialized struct.
     */

    public init(destImageSize: Int = 60, sourceImageDownSizingTileSize: Int = 20, tileSize: Int = 256) {
        self.destImageSizeMB = destImageSize
        self.sourceImageTileSizeMB = sourceImageDownSizingTileSize
        self.tileSize = tileSize
    }

    /**
     A method for getting the url of tiles for each tiled image.
     This method returns a directory url.
     - Parameter imageName: name of image that needs its tiles url
     - Returns: url of tiles respect to name of image passed.
     */
    public func urlOfTiledImage(named imageName: String) -> URL {

        let destinationURL = fileManager.temporaryDirectory.appendingPathComponent("TileManager", isDirectory: true).appendingPathComponent(imageName, isDirectory: true)
        if !fileManager.fileExists(atPath: destinationURL.path) {

            do {

                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)

            } catch let error {
                fatalError("cant create directory at \(destinationURL), cause error: \(error)")
            }

        }

        return destinationURL
    }

    /**
     A method for getting placeholder image of each tiled image.
     This placeholder is created the first time the tiles of each image being created.
     - Parameter imageName: name of image that needs its placeholder image url
     - Returns: url of placeholder image respect to name of image passed.
     */
    public func urlOfPlaceholderOfImage(named imageName: String) -> URL? {
        let directoryURL = urlOfTiledImage(named: imageName)
        let imageName = "\(imageName)_Placeholder.jpg"
        let url = directoryURL.appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }

    /**
     Removes directory of tiles respect to each tiled image if exist.
     - Parameter imageName: name of image that needs to remove its tiles.
     */
    public func removeTilesForImage(named imageName: String) {
        let url = urlOfTiledImage(named: imageName)
        do {
            try self.fileManager.removeItem(at: url)
        } catch {
            os_log("Error: %@", log: mLog, type: .debug, error.localizedDescription)
        }
    }

    /**
     Removes directory of whole tiles that created for this app.
     */
    public func clearCache() {
        let tileManagerURL = fileManager.temporaryDirectory.appendingPathComponent("TileManager", isDirectory: true)
        do {
            try self.fileManager.removeItem(at: tileManagerURL)
        } catch {
            os_log("Error: %@", log: mLog, type: .debug, error.localizedDescription)
        }
    }

    /**
     Checks whether it is needed to make tiles for the image that passed its url.
     This method compares resolution of passed url's image with phone screen resolution
     - Parameter url: The url of image that want to check its need to tiling.
     - Returns: Returns true if image resolution is bigger than phone screen resolution otherwise
     returns false
     */
    public func needsTilingImage(in url: URL) -> Bool {
        do {

            let sourceResolution = try resolutionForImage(in: url)

            let sourceMaximumEdge: CGFloat = sourceResolution.width > sourceResolution.height ? sourceResolution.width : sourceResolution.height

            let screenTotalSize = UIScreen.main.bounds.size
            let screenScale = UIScreen.main.scale

            let screenMinimumEdge: CGFloat = screenTotalSize.width < screenTotalSize.height ? screenTotalSize.width : screenTotalSize.height

            return sourceMaximumEdge > screenMinimumEdge*screenScale

        } catch {
            os_log("Error: %@", log: mLog, type: .error, error.localizedDescription)
        }

        return false
    }

    /**
     Checks whether tiles made for the image that passed its url.
     - Parameter imageName: name of image that needs to check.
     - Returns: Returns true if tiles are exist for image that passed its url.
     */
    public func tilesMadeForImage(named imageName: String) -> Bool {
        return urlOfImageInfoForImage(named: imageName) != nil
    }

    /**
     - Parameter imageName: name of image that needs its size.
     - Returns: Returns the resolution size of image that its tiles are made. This value is saved in a **plist** file next to the tiles.
     */
    public func sizeOfTiledImage(named imageName: String) -> CGSize? {
        if let url = urlOfImageInfoForImage(named: imageName) {
            let plist = NSArray(contentsOf: url)
            if let dic = plist!.lastObject as? [String: Any] {
                let width = dic["width"] as? CGFloat ?? 0
                let height = dic["height"] as? CGFloat ?? 0
                let size = CGSize(width: width, height: height)
                return size
            }
        }
        return nil
    }

    public func sizeOfCordSpace(named imageName: String) -> CGSize? {
        if let url = urlOfImageInfoForImage(named: imageName) {
            let plist = NSArray(contentsOf: url)
            if let dic = plist!.lastObject as? [String: Any] {
                let width = dic["xmax"] as? CGFloat ?? 0
                let height = dic["ymax"] as? CGFloat ?? 0
                let size = CGSize(width: width, height: height)
                return size
            }
        }
        return nil
    }

    public func checkCacheDate(named imageName: String) -> Date? {
        if let url = urlOfImageInfoForImage(named: imageName) {
            let plist = NSArray(contentsOf: url)
            if let dic = plist!.lastObject as? [String: Any] {
                let date = dic["date"] as? Date
                return date
            }
        }
        return nil
    }

    /**
     - Parameter url: url of image that needs its resolution size.
     - Returns: Returns the resolution size of image that passed its url.
     */
    public func resolutionForImage(in url: URL) throws -> CGSize {
        // create an image from the image filename constant. Note this
        //  doesn't actually read any pixel information from disk, as that
        // is actually done at draw time.
        let path = url.path

        // The input image file
        var sourceImage: UIImage?
        sourceImage = UIImage(contentsOfFile: path)
        guard  sourceImage != nil else {
            throw TileMakerError.inputImageNotFound
        }

        // get the width and height of the input image using
        // core graphics image helper functions.
        let sourceResolution = CGSize(width: CGFloat(sourceImage!.cgImage!.width), height: CGFloat(sourceImage!.cgImage!.height))
        os_log("the resolution is: %@", log: mLog, type: .debug, sourceResolution.debugDescription)
        return sourceResolution
    }

    /**
     This method calculate that how would be the resolution of image that passed its url if it being down sized with the parameter of initializer.
     - Parameter url: url of image that needs its resolution size.
     - Returns: Returns the destination resolution size of image that passed its url.
     */
    public func destinationResolutionForImage(in url: URL) throws -> CGSize {
        do {
            // get the width and height of the input image using
            // core graphics image helper functions.
            let sourceResolution = try self.resolutionForImage(in: url)

            // use the width and height to calculate the total number of pixels
            // in the input image.
            let sourceTotalPixels = sourceResolution.width * sourceResolution.height

            // determine the scale ratio to apply to the input image
            // that results in an output image of the defined size.
            // see destImageSizeMB, and how it relates to destTotalPixels.

            let imageScale: CGFloat = self.downSizeSourceImage ? CGFloat(self.destTotalPixels) / sourceTotalPixels : 1.0

            // use the image scale to calcualte the output image width, height
            let destResolution = CGSize(width: sourceResolution.width * imageScale, height: sourceResolution.height * imageScale)

            return destResolution

        } catch let error {

            throw error
        }
    }

    /**
     This method calculate that total size (in megabyte) of image that passed its url when it is uncompressed and loaded in memory.
     - Parameter url: url of image that needs its total megabyte size in memory.
     - Returns: Returns total megabyte size of image in memory.
     */
    public func totalMBForImage(in url: URL) throws -> CGFloat {
        do {

            // get the width and height of the input image using
            // core graphics image helper functions.
            let sourceResolution = try self.resolutionForImage(in: url)

            // use the width and height to calculate the total number of pixels
            // in the input image.
            let sourceTotalPixels = sourceResolution.width * sourceResolution.height

            // calculate the number of MB that would be required to store
            // this image uncompressed in memory.
            let sourceTotalMB = sourceTotalPixels / CGFloat(self.pixelsPerMB)

            return sourceTotalMB

        } catch let error {

            throw error
        }
    }

    /**
     Down sizes, makes placeholder and Tiles for given image url.

     - Parameters:
     - url: url of image that needs to make tiles for it
     - placeholderCompletion:
     A block to be executed when the making of placeholder ends. This block has no return value and takes url argument of created placeholder image and error argument for creating placholder. url may be nil if an error occurs about making placeholder. Error will be nil if no error occurs.

     - tilingCompletion:
     A block to be executed when the making of tiles ends. This block has no return value and takes
     three argument. An String and CGSize as name and size of tiled image, an error if some errors happened.
     If an error occurs, String and CGSize arguments may be nil. If no error occurs, Error will be nil.
     */
    public func makeTiledImage(for url: URL, placeholderCompletion: @escaping (URL?, Error?) -> Swift.Void, tilingCompletion: @escaping (String?, CGSize?, Error?) -> Swift.Void) {
        // create an image from the image filename constant. Note this
        //  doesn't actually read any pixel information from disk, as that
        // is actually done at draw time.

        // The input image file
        guard let sourceImage = UIImage(contentsOfFile: url.path) else {
            os_log("Error: input image not found!", log: mLog, type: .error)
            DispatchQueue.main.async {
                tilingCompletion(nil, nil, TileMakerError.inputImageNotFound)
            }
            return
        }

        let imageNamePrefix = "tile"//url.deletingPathExtension().lastPathComponent

        let destinationURL = self.urlOfTiledImage(named: imageNamePrefix)

        self.makePlaceholder(for: sourceImage.cgImage!, to: destinationURL, usingPrefix: imageNamePrefix) { (url, error) in
            if error != nil {
                DispatchQueue.main.async {
                    tilingCompletion(nil, nil, error)
                }
                return
            } else {
                DispatchQueue.main.async {
                    placeholderCompletion(url, error)
                }
            }
        }

        self.downSize(sourceImage, completion: { (image, error) in
            guard error == nil else {
                DispatchQueue.main.async {
                    tilingCompletion(nil, nil, error)
                }
                return
            }

            self.makeTiles(for: image!, to: destinationURL, usingPrefix: imageNamePrefix, tilingCompletion: { (imageName, imageSize, error) in

                DispatchQueue.main.async {
                    tilingCompletion(imageName, imageSize, error)
                }
            })

        })

    }

    /**
     A method for getting url of **imageInfo.plist** that contains name, width and height of each tiled image.
     This file is created the first time the tiles of each image being created.
     - Parameter imageName: name of image that needs its imageInfo.plist file url
     - Returns: url of imageInfo.plist respect to name of image passed.
     */
    private func urlOfImageInfoForImage(named imageName: String) -> URL? {
        let directoryURL = urlOfTiledImage(named: imageName)
        os_log("Directory URL is : %@", log: mLog, type: .debug, directoryURL.path)
        let url = directoryURL.appendingPathComponent("imageInfo.plist")
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }

    /**
     Down size given image to an image with the size of megabyte that specified in initializer.

     - Parameters:
     - sourceImage: The imgae want to downsize it
     - completion:  A block to be executed when the down sizing ends. I takes two argument. the downsized image as CGImage and error. If an error occurs the CGImage may be nil. if no error occurs, Error will be nil.
     */
    private func downSize(_ sourceImage: UIImage, completion: @escaping (CGImage?, Error?) -> Void) {

        /* the temporary container used to hold the resulting output image pixel
         data, as it is being assembled. */
        var destContext: CGContext!

        DispatchQueue.global().async {

            autoreleasepool {

                //                guard let sourceImage = UIImage(contentsOfFile: path) else {
                //                    print("error: input image not found!")
                //                    completion(nil, TileMakerError.inputImageNotFound)
                //                    return
                //                }

                // get the width and height of the input image using
                // core graphics image helper functions.
                let sourceResolution = CGSize(width: CGFloat(sourceImage.cgImage!.width), height: CGFloat(sourceImage.cgImage!.height))

                // use the width and height to calculate the total number of pixels
                // in the input image.
                let sourceTotalPixels = sourceResolution.width * sourceResolution.height

                // calculate the number of MB that would be required to store
                // this image uncompressed in memory.
                let sourceTotalMB = sourceTotalPixels / CGFloat(self.pixelsPerMB)

                // determine the scale ratio to apply to the input image
                // that results in an output image of the defined size.
                // see destImageSizeMB, and how it relates to destTotalPixels.
                var imageScale: CGFloat = self.downSizeSourceImage ? CGFloat(self.destTotalPixels) / sourceTotalPixels : 1.0

                if Int(sourceTotalMB) <= self.destImageSizeMB {
                    imageScale = 1.0
                }

                // use the image scale to calcualte the output image width, height
                let destResolution = CGSize(width: sourceResolution.width * imageScale, height: sourceResolution.height * imageScale)

                // create an offscreen bitmap context that will hold the output image
                // pixel data, as it becomes available by the downscaling routine.
                // use the RGB colorspace as this is the colorspace iOS GPU is optimized for.
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let bytesPerRow = self.bytesPerPixel * Int(destResolution.width)

                // create the output bitmap context
                destContext = CGContext(data: nil, width: Int(destResolution.width), height: Int(destResolution.height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

                // remember CFTypes assign/check for NULL. NSObjects assign/check for nil.
                if destContext == nil {
                    completion(nil, TileMakerError.failedToCreateTheOutputBitmapContext)
                    os_log("failed to create the output bitmap context!", log: self.mLog, type: .error)
                    return
                }

                // flip the output graphics context so that it aligns with the
                // cocoa style orientation of the input document. this is needed
                // because we used cocoa's UIImage -imageNamed to open the input file.
                destContext.translateBy(x: 0, y: destResolution.height)
                destContext.scaleBy(x: 1, y: -1)

                // now define the size of the rectangle to be used for the
                // incremental blits from the input image to the output image.
                // we use a source tile width equal to the width of the source
                // image due to the way that iOS retrieves image data from disk.
                // iOS must decode an image from disk in full width 'bands', even
                // if current graphics context is clipped to a subrect within that
                // band. Therefore we fully utilize all of the pixel data that results
                // from a decoding opertion by anchoring our tile size to the full
                // width of the input image.
                var sourceTile = CGRect.zero
                sourceTile.size.width = sourceResolution.width

                // the source tile height is dynamic. Since we specified the size
                // of the source tile in MB, see how many rows of pixels height
                // can be given the input image width.
                sourceTile.size.height = floor(CGFloat(self.tileTotalPixels) / sourceTile.size.width)
                os_log("source tile size: %@", log: self.mLog, type: .debug, sourceTile.size.debugDescription)
                //            sourceTile.origin.x = 0.0

                // the output tile is the same proportions as the input tile, but
                // scaled to image scale.
                var destTile = CGRect.zero
                destTile.size.width = destResolution.width
                destTile.size.height = sourceTile.size.height * imageScale
                //            destTile.origin.x = 0.0

                os_log("Source tile size: %@", log: self.mLog, type: .debug, sourceTile.size.debugDescription)

                // the SeamOverlap is the number of pixels to overlap tiles as they are assembled.
                // the source seam overlap is proportionate to the destination seam overlap.
                // this is the amount of pixels to overlap each tile as we assemble the ouput image.
                let sourceSeamOverlap = floor((CGFloat(self.destSeamOverlap) / destResolution.height) * sourceResolution.height)
                os_log("Dest seam overlap: %f,source seam overlap:%f", log: self.mLog, type: .debug, self.destSeamOverlap, sourceSeamOverlap)

                var sourceTileImage: CGImage!

                // calculate the number of read/write opertions required to assemble the
                // output image.
                var iterations = Int(sourceResolution.height / sourceTile.height)

                // if tile height doesn't divide the image height evenly, add another iteration
                // to account for the remaining pixels.
                let remainder = Int(sourceResolution.height.truncatingRemainder(dividingBy: sourceTile.size.height))
                if remainder != 0 {
                    iterations += 1
                }

                // add seam overlaps to the tiles, but save the original tile height for y coordinate calculations.
                let sourceTileHeightMinusOverlap = sourceTile.size.height
                sourceTile.size.height += sourceSeamOverlap
                destTile.size.height += CGFloat(self.destSeamOverlap)

                //                print("beginning downsize. iterations: \(iterations), tile height: \(sourceTile.size.height), remainder height: \(remainder)")

                for y in 0..<iterations {

                    // create an autorelease pool to catch calls to -autorelease made within the downsize loop.
                    autoreleasepool {

                        //                        print("iteration \(y+1) of \(iterations)")

                        sourceTile.origin.y = CGFloat(y) * sourceTileHeightMinusOverlap + CGFloat(sourceSeamOverlap)
                        destTile.origin.y = (destResolution.height ) - ( ( CGFloat(y) + 1 ) * sourceTileHeightMinusOverlap * imageScale + CGFloat(self.destSeamOverlap))

                        // create a reference to the source image with its context clipped to the argument rect.
                        sourceTileImage = sourceImage.cgImage?.cropping(to: sourceTile)

                        // if this is the last tile, it's size may be smaller than the source tile height.
                        // adjust the dest tile size to account for that difference.
                        if y == iterations - 1 && remainder != 0 {
                            var dify = destTile.size.height
                            destTile.size.height = CGFloat(sourceTileImage.height) * imageScale
                            dify -= destTile.size.height
                            destTile.origin.y += dify
                        }

                        // read and write a tile sized portion of pixels from the input image to the output image.
                        destContext.draw(sourceTileImage, in: destTile)
                    }
                }

                //                print("downsize complete.")

                if let image = destContext.makeImage() {
                    completion(image, nil)
                } else {
                    completion(nil, TileMakerError.destinationContextFailedToMakeImage)
                }

            }
        }
    }

    /**
     Make tiles in 4 diferent scale for given image and save tiles in given directory url. The scales are 0.125, 0.25, 0.5, 1.0 .

     - Parameters:
     - image: image that wants make tiles for it
     - directoryURL: destination url want tiles save there.
     - prefix: The name that uses for naming tiles of image.
     - tilingCompletion:
     A block to be executed when the making of tiles ends. This block has no return value and takes
     three argument. An String and CGSize as name and size of tiled image, an error if some errors happened.
     If an error occurs, String and CGSize arguments may be nil. If no error occurs, Error will be nil.
     */
    private func makeTiles(for image: CGImage, to directoryURL: URL, usingPrefix prefix: String, tilingCompletion: @escaping (String?, CGSize?, Error?) -> Void) {
        DispatchQueue.global().async {

            var scale: CGFloat = 0.125
            var iterations: Int = 4
            let imageMaxEdge = image.width > image.height ? image.width : image.height
            let screenSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            let screenMinEdge = screenSize.width > screenSize.height ? screenSize.width : screenSize.height
            let screenScale = UIScreen.main.scale
            let ratio = (screenMinEdge*screenScale*0.2)/CGFloat(imageMaxEdge)

            if ratio > 0.125, ratio <= 0.25 {
                scale = 0.25
                iterations = 3
            }
            if ratio > 0.25, ratio <= 0.5 {
                scale = 0.5
                iterations = 2
            }
            if ratio > 0.5 {
                scale = 1
                iterations = 1
            }

            DispatchQueue.concurrentPerform(iterations: iterations, execute: { (count) in
                self.makeTiles(for: image, inScale: scale*pow(2, CGFloat(count)), to: directoryURL, usingPrefix: prefix) { (error) in
                    if error != nil {
                        tilingCompletion(nil, nil, error)
                        return
                    }
                }

            })

            let imageWidth = CGFloat(image.width)
            let imageHeight = CGFloat(image.height)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
            self.add(imageName: prefix, with: imageSize, toPropertyListAt: directoryURL) { (error) in
                if error != nil {
                    tilingCompletion(nil, nil, error)
                } else {
                    tilingCompletion(prefix, imageSize, nil)

                }
            }
        }
    }

    /**
     Make tiles in 4 diferent scale for given image and save tiles in given directory url. The scales are 0.125, 0.25, 0.5, 1.0 .

     - Parameters:
     - imageName: Name of image that wants to save its information in its info propertylist
     - size: size of image that wants to save its information in its info propertylist
     - propertyListURL: destination url want tiles save there.
     - completion:
     A block to be executed when saving information to propertyList ends. This block has no return value and takes
     one argument. An error if some errors happened. If no error occurs, Error will be nil.
     */
    private func add(imageName: String, with size: CGSize, toPropertyListAt propertyListURL: URL, completion: (Error?) -> Void) {
        let dic: [String: Any] = ["name": imageName, "width": size.width, "height": size.height]

        let fileManager = FileManager.default
        let url = propertyListURL.appendingPathComponent("imageInfo.plist")

        do {
            if fileManager.fileExists(atPath: url.path) {
                let plistArray = NSMutableArray(contentsOf: url)
                plistArray?.add(dic)

                if #available(iOS 11.0, *) {
                    try plistArray?.write(to: url)
                } else {
                    guard let stream = OutputStream(url: url, append: true) else { return }
                    PropertyListSerialization.writePropertyList(plistArray!, to: stream, format: PropertyListSerialization.PropertyListFormat.xml, options: 0, error: nil)
                }

                /* Serializes this instance to the specified URL in the NSPropertyList format (using NSPropertyListXMLFormat_v1_0). For other formats use NSPropertyListSerialization directly. */

                completion(nil)
            } else {
                if #available(iOS 11.0, *) {
                   try NSArray(array: [dic]).write(to: url)
                } else {
                    guard let stream = OutputStream(url: url, append: true) else { return  }
                    PropertyListSerialization.writePropertyList([dic], to: stream, format: PropertyListSerialization.PropertyListFormat.xml, options: 0, error: nil)
                }
                completion(nil)
            }
        } catch let error {
            print(error)
            completion(error)
        }
    }

    /**
     Make placeholder for given image and save it in given directory url.

     - Parameters:
     - image: image that wants make placeholder for it
     - directoryURL: destination url want placeholder save there.
     - prefix: The name that uses for naming placeholder of image.
     - completion:
     A block to be executed when the making of tiles ends. This block has no return value and takes
     two argument. A URL and Error as url of placeholder, and error if some errors happened.
     If an error occurs, url may be nil. If no error occurs, Error will be nil.
     */
    private func makePlaceholder(for image: CGImage, to directoryURL: URL, usingPrefix prefix: String, completion: @escaping (URL?, Error?) -> Void) {
        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)

        let scale = UIScreen.main.bounds.width/imageWidth
        let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth*scale, height: imageHeight*scale))

        DispatchQueue.global().async {

            UIGraphicsBeginImageContext(imageRect.size)
            let context = UIGraphicsGetCurrentContext()

            context?.saveGState()
            context?.translateBy(x: 0, y: imageRect.size.height)
            context?.scaleBy(x: 1, y: -1)

            context?.draw(image, in: imageRect)
            context?.restoreGState()
            let lowQImage = context?.makeImage()
            UIGraphicsEndImageContext()
            let imageData = UIImage(cgImage: lowQImage!).pngData()

            let imageName = "\(prefix)_Placeholder.png"
            let url = directoryURL.appendingPathComponent(imageName)
            do {
                try imageData!.write(to: url)
            } catch let error {
                completion(nil, error)
            }
            completion(url, nil)
        }
    }

    /**
     Make tiles in given scale for given image and save tiles in given directory url.

     - Parameters:
     - size: Size that wants make tiles in that size. Default is nil and uses the size specified with initializer
     - image: Image that wants make tiles for it.
     - scale: Scale that wants make tiles for that scale.
     - directoryURL: destination url want tiles save there.
     - prefix: The name that uses for naming tiles of image.
     - completion:
     A block to be executed when saving information to propertyList ends. This block has no return value and takes
     one argument. An error if some errors happened. If no error occurs, Error will be nil.
     */
    private func makeTiles( in size: CGSize? = nil, for image: CGImage, inScale scale: CGFloat, to directoryURL: URL, usingPrefix prefix: String, completion: (Error?) -> Void) {
        let size = size ?? CGSize(width: self.tileSize, height: self.tileSize)

        var image: CGImage! = image

        let imageWidth = CGFloat(image.width)
        let imageHeight = CGFloat(image.height)

        let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth*scale, height: imageHeight*scale))
        var context: CGContext!
        if scale != 2 {
            UIGraphicsBeginImageContext(imageRect.size)
            context = UIGraphicsGetCurrentContext()

            context?.saveGState()

            context?.draw(image!, in: imageRect)
            context?.restoreGState()
            image = context.makeImage()
            UIGraphicsEndImageContext()
        }

        let cols = imageRect.width/size.width
        let rows = imageRect.height/size.height

        var fullColomns = floor(cols)
        var fullRows = floor(rows)

        let remainderWidth = imageRect.width - fullColomns*size.width
        let remainderHeight = imageRect.height - fullRows*size.height

        if cols > fullColomns { fullColomns += 1 }
        if rows > fullRows { fullRows += 1 }

        let fullImage = image!

        for row in 0..<Int(fullRows) {
            for col in 0..<Int(fullColomns ) {
                var tileSize = size
                if col + 1 == Int(fullColomns) && remainderWidth > 0 {
                    // Last Column
                    tileSize.width = remainderWidth
                }
                if row + 1 == Int(fullRows) && remainderHeight > 0 {
                    // Last Row
                    tileSize.height = remainderHeight
                }

                autoreleasepool {

                    let tileImage = fullImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(col)*size.width, y: CGFloat(row)*size.height), size: tileSize))!
                    let imageData = UIImage(cgImage: tileImage).pngData()

                    let tileName = "\(Int(scale*1000))\\\(prefix)_\(col)_\(row).png"
                    let url = directoryURL.appendingPathComponent(tileName)
                    do {
                        try imageData!.write(to: url)
                    } catch {
                        completion(error)
                        return
                    }
                }
            }
        }
        context = nil
        completion(nil)
    }

}
