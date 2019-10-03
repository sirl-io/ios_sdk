//
//  SirlSearchResultCell.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/15/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit

class SirlSearchResultCell: UITableViewCell {

    let resultImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.image = UIImage(named: "noImage")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let resultText: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.translatesAutoresizingMaskIntoConstraints = false
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        addSubview(resultImageView)
        addSubview(resultText)
        resultImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
        resultImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        resultImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        resultImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        resultText.rightAnchor.constraint(equalTo: resultImageView.leftAnchor, constant: -5).isActive = true
        resultText.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        resultText.heightAnchor.constraint(equalToConstant: 25).isActive = true
        resultText.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been inplemented")
    }

}
