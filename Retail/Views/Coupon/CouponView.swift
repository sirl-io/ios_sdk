//
//  CouponView.swift
//  Westside
//
//  Created by Wei Cai on 4/24/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
class CouponView: UIView,
                 UICollectionViewDelegate,
                 UICollectionViewDataSource,
                 UICollectionViewDelegateFlowLayout {

    private let cellID = "couponItem"
    private let raffleID = "raffleItem"
    private let sideMargin: CGFloat = 10

    public var areCouponsAvalible: Bool {
        return coupons.count > 0
    }

    private var coupons: [Coupon] = [] {
        didSet {
            DispatchQueue.main.async {
                self.counponListView.reloadData()
            }
        }
    }

    let counponListView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
        cv.backgroundColor = sirlLightBtnColor
        let collectionViewFLowLayout = UICollectionViewFlowLayout()
        collectionViewFLowLayout.scrollDirection = .horizontal
        collectionViewFLowLayout.minimumLineSpacing = 0
        cv.setCollectionViewLayout(collectionViewFLowLayout, animated: true)
        cv.isPagingEnabled = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configView()
        self.configCouponView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadAvailableCoupons(completeion:(() -> Void)? = nil) {
        SIRLCouponService.shared.getAvailableCoupons { (coupons) in
            self.coupons = coupons
            completeion?()
        }
    }

    func configView() {
        self.clipsToBounds = true
        self.addSubview(counponListView)
        counponListView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        counponListView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        counponListView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        counponListView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }

    func configCouponView() {
        counponListView.register(CouponCell.self, forCellWithReuseIdentifier: cellID)
        counponListView.register(RaffleCell.self, forCellWithReuseIdentifier: raffleID)
        counponListView.delegate = self
        counponListView.dataSource = self
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.coupons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let coupon = coupons[indexPath.row]
        if coupon.type == "Raffle" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: raffleID, for: indexPath) as! RaffleCell
            cell.coupon = coupon
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CouponCell
            cell.coupon = coupon
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.bounds.width, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sideMargin, left: 0, bottom: sideMargin, right: 0)
    }

}
