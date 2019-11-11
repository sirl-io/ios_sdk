//
//  File.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 8/19/19.
//  Copyright © 2019 Wei Cai. All rights reserved.
//

import Foundation
#if canImport(SIRLCore)
import SIRLCore
#endif

public class StorePromotions: Decodable {
    public var promotions: [Promotion]?
    public func fetchLocations(completion: ((Error?) -> Void)?) {
        if #available(iOS 10.0, *) {
            guard let promos = promotions else {return}
            var productIds: [String] = []
            var map: [String: Int] = [:]
            let storeId = 2
            for (index, promo) in promos.enumerated() {
                guard let promoId = promo.id else {return}
                productIds.append(promoId)
                map[promoId] = index
            }
            SirlAPIClient.shared.send(FindStoreItems(storeId: storeId, productIds: productIds)) {
                (res) in
                switch (res) {
                case .failure(let err):
                    completion?(err)
                case .success(let products):
                    self.processLocations(products: products, map: map)
                    completion?(nil)
                }
            }
        }
    }

    private func processLocations(products: [StoreProduct], map: [String: Int]) {
        guard let promos = promotions else {return}
        for product in products {
            if let proId = product.productId {
                if let index = map[proId] {
                    promos[index].center = product.location
                }
            }
        }
    }

    public func getPromotion(_ id: String) -> Promotion? {
        guard let promos = promotions else {return nil}
        for promo in promos {
            if let pid = promo.id {
                if id == String(pid) {
                    return promo
                }
            }
        }
        return nil
    }
}

public class Promotion: SirlGeoFence, Decodable {
    public var companyId: Int?
    public var expires: String?
    public var image: String?
    public var storeId: Int?
    public var title: String?
    public var details: String?
    public var promotionCode: String?
    public var allowNavigation: Bool?

    enum CodingKeys: String, CodingKey {
        case companyId
        case productId
        case expires
        case image
        case storeId
        case requiredDwellDuration
        case margin
        case title
        case description
        case couponCode
        case navigate
    }

    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let companyId = try container.decode(Int.self, forKey: .companyId)
        let storeId = try container.decode(Int.self, forKey: .storeId)
        let duration = try container.decode(Int.self, forKey: .requiredDwellDuration)
        let productId = try container.decode(String.self, forKey: .productId)
        let expires = try container.decode(String.self, forKey: .expires)
        let image = try container.decode(String.self, forKey: .image)
        let margin = try container.decode(Double.self, forKey: .margin)
        let title = try container.decode(String.self, forKey: .title)
        let details = try container.decode(String.self, forKey: .description)
        let promoCode = try container.decodeIfPresent(String.self, forKey: .couponCode)
        let allowNav = try container.decodeIfPresent(Bool.self, forKey: .navigate)
        self.init(companyID: companyId, expires: expires, image: image,
                  storeId: storeId, geoId: productId, requiredDwellDuration: duration, margin: margin,
                  title: title, details: details, navigate: allowNav, promotionCode: promoCode)
    }

    public init(companyID: Int, expires: String, image: String?,
                storeId: Int, geoId: String, requiredDwellDuration: Int, margin: Double,
                title: String, details: String, navigate: Bool?, promotionCode: String?) {
        super.init()
        self.companyId = companyID
        self.expires = expires
        self.image = image
        self.storeId = storeId
       // self.id = geoId
        self.requiredDwellDuration = requiredDwellDuration
        self.margin = margin
        self.title = title
        self.details = details
        self.allowNavigation = navigate
        self.promotionCode = promotionCode
    }

    public func getExpireDate() -> Date? {
        guard let iosDate = self.expires else {
            return nil
        }
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        return dateFormater.date(from: iosDate)
    }

}
