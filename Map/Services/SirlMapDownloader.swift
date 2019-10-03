//
//  SirlMapLoader.swift
//  SirlSDK
//
//  Created by Wei Cai on 9/14/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
import os.log
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class SirlMapDownLoader {
    let fileManager = FileManager.default
    let zdl: ZipFileDownloader!
    var mapFileLocation: URL!
    public init() {
        zdl = ZipFileDownloader()
        do {
            let documentDir = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            mapFileLocation = documentDir.appendingPathComponent("SirlMap", isDirectory: true)
        } catch _ {

        }
    }

    public func download(url: String, ML_ID: String, completion:@escaping (URL) -> Void) {
        let mapPath = mapFileLocation.appendingPathComponent(ML_ID, isDirectory: true)
        let destPath = mapPath.appendingPathComponent("tiles", isDirectory: true)
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: destPath.path, isDirectory: &isDir) && isDir.boolValue {
            do {
                try fileManager.createDirectory(at: destPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                fatalError("Error creating folder for mlID \(ML_ID). \(error)")
            }
        }
        zdl.download(url: url, to: destPath.path) {
            completion(mapPath)
        }
    }

}
