//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 8/29/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class PromotionService {
    public static let shared = PromotionService()
    public func fetchPromotions(completion: @escaping (StorePromotions?) -> Void ) {
        SirlAPIClient.shared.send(FetchPromotions(storeId: 2)) { (res) in
            switch res {
            case .failure:
                return
            case .success(let result):
                result.fetchLocations(completion: { (err) in
                    if err != nil {
                        print(err ?? "")
                    }
                    if let geoFences = result.promotions {
                       SirlCoreImpl.shared.registerGeoFence(geoFences: geoFences)
                       completion(result)
                    }
                })
            }
        }
    }
}
