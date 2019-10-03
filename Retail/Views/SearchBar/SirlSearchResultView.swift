//
//  SirlSearchResultView.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/15/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit

protocol SirlSearchResultDelegate: class {
    func didSelectProduct(product: StoreProduct)
}

class SirlSearchResultView: UIView, UITableViewDelegate, UITableViewDataSource {

    private var lastSelect: IndexPath?
    private let dropdownCellHeight: CGFloat = 58.8
    private var didSelectItem: Bool = false
    private let cellId = "CellID"
    internal weak var delegate: SirlSearchResultDelegate?

    private var searchResultView: UITableView = {
        let srv = UITableView()
        srv.separatorStyle = .singleLine
        srv.layoutMargins = UIEdgeInsets.zero
        srv.separatorInset = UIEdgeInsets.zero
        srv.layer.borderWidth = 0.5
        srv.layer.borderColor = UIColor.black.cgColor
        srv.translatesAutoresizingMaskIntoConstraints = false
        return srv
    }()

    private var tableViewTopConstrain: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            tableViewTopConstrain?.isActive = true
        }
    }

    var tableViewTopOffset: CGFloat? {
        didSet {
            if let tableViewTopOffset = self.tableViewTopOffset {
                self.layoutTableViewTop(tableViewTopOffset)
            }
        }
    }

    var searchResult: [StoreProduct]? {
        didSet {
            DispatchQueue.main.async {
                self.tableViewHeightAnchor?.isActive = true
                guard let result = self.searchResult,
                    !result.isEmpty else {
                        self.searchResultView.reloadData()
                        return
                }
                if let mLastSelectedIndex = self.lastSelect {
                    self.searchResultView.deselectRow(at: mLastSelectedIndex, animated: false)
                }
                self.searchResultView.reloadData()
            }
        }
    }

    internal var keyboardHeight: CGFloat = 0 {
        didSet {
            self.setBottomAnchor()
            self.tableViewHeightAnchor?.isActive = true
        }
    }

    private func setBottomAnchor() {
        var btmAnchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            btmAnchor = keyboardHeight > 0 ? self.bottomAnchor : self.safeAreaLayoutGuide.bottomAnchor
        } else {
            btmAnchor = self.bottomAnchor
        }

        self._tableViewBottomAncor = self.searchResultView
            .bottomAnchor
            .constraint(lessThanOrEqualTo: btmAnchor,
            constant: -10-keyboardHeight)
    }

    private var _tableViewBottomAncor: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            _tableViewBottomAncor?.isActive = true
        }
    }

    private var _tableViewHeightAnchor: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
        }
    }

    private var tableViewHeightAnchor: NSLayoutConstraint? {
        var count = 0
        if let sr = self.searchResult {
            count = sr.count
        }
        _tableViewHeightAnchor = self.searchResultView.heightAnchor.constraint(equalToConstant: CGFloat(count) * dropdownCellHeight)
        return _tableViewHeightAnchor
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configTableView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:)has not been inplemented")
    }

    private func layoutTableViewTop(_ tableViewTopOffset: CGFloat) {
        self.tableViewTopConstrain = self.searchResultView.topAnchor.constraint(equalTo: self.topAnchor, constant: tableViewTopOffset)
    }

    private func layoutTableView() {
        if #available(iOS 11.0, *) {
            self.searchResultView.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, constant: -25).isActive = true
            self.searchResultView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        } //TODO test if this is needed else {
//            self.searchResultView.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor, constant: -25).isActive = true
//            self.searchResultView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
//        }

        self.setBottomAnchor()
    }

    func configTableView() {
        self.addSubview(self.searchResultView)
        self.searchResultView.register(SirlSearchResultCell.self, forCellReuseIdentifier: cellId)
        self.searchResultView.delegate = self
        self.searchResultView.dataSource = self
        self.layoutTableView()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mSearchResut = searchResult {
            return mSearchResut.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let mSearchResult = searchResult else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SirlSearchResultCell
        cell.layoutMargins = UIEdgeInsets.zero
        guard indexPath.row < mSearchResult.count else {
            return UITableViewCell()
        }
        cell.resultText.text = mSearchResult[indexPath.row].product?.name
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dropdownCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectItem = true
        lastSelect = indexPath
        guard let mSearchResult = searchResult  else {return}
        guard indexPath.row < mSearchResult.count else {return}
        delegate?.didSelectProduct(product: mSearchResult[indexPath.row])
    }

}
