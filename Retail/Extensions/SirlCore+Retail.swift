//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 9/24/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

public extension SirlCore {
    @objc func recordProductScan(id: String, type: String, rightSide: Bool) {
        if #available(iOS 10.0, *) {
            if let recorder = SirlCoreImpl.shared.executionLog {
                recorder.productScanEvent(id: id, type: type, rightSide: rightSide)
            }
        }
    }
}
