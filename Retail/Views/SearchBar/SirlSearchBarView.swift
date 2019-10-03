//
//  SirlSearchBarView.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 3/15/19.
//  Copyright © 2019 SIRL Inc. All rights reserved.
//

import UIKit
import os.log
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public protocol SirlSearchBarViewDelegate: class {
    func didSelectProduct(location: sirlLocation, product: StoreProduct)
    func didPressSearchBarButton()
}

@IBDesignable
@available(iOS 10.0, *)
public class SirlSearchBar: UIView, UITextFieldDelegate, SirlSearchResultDelegate {

    private let cellId = "CellID"
    private let apiClient = SirlAPIClient.shared
    private let core = SirlCoreImpl.shared
    private var buttonTimer: Timer?
    private let mLog = OSLog(subsystem: "com.sirl.Search_Bar", category: "Sirl_Search_Bar")
    private enum barButtonState {
        case searching
        case normal
    }

    private var currentBarButtonState: barButtonState = .normal {
        didSet {
            switch currentBarButtonState {
            case .searching:
                self.barButton.setImage(backImage, for: .normal)
            case .normal:
                self.barButton.setImage(menuImage, for: .normal)
            }
        }
    }

    private var searchDelayTimer: Timer?
    public weak var delegate: SirlSearchBarViewDelegate?
    public var mapView: SirlMapView?

    private var elog: SirlTripExecutionLogRecorder? {
        return SirlTripDataReporter.shared.executionLog
    }

    private var currentProduct: StoreProduct? {
        didSet {
            self.mTextField.text = currentProduct?.product?.name
            self.searchResultView.searchResult = [StoreProduct]()
            if currentProduct == nil {
                self.mapView?.resetDestination()
                closeButton.isEnabled = false
            } else {
                if let product = currentProduct,
                   let location = product.location {
                    if let pid = product.product?.id {
                        self.elog?.retailEvent(type: .route, content: pid)
                    }
                     self.mapView?.updateDestination(location: location, destinationDescription: product.product?.name)
                     self.delegate?.didSelectProduct(location: location, product: product)
                    }
                closeButton.isEnabled = true
            }
        }
    }

    private var mlID: UInt32? {
        return core.ML_ID
    }

    private var searchResultView: SirlSearchResultView = {
        let srv = SirlSearchResultView()
        srv.translatesAutoresizingMaskIntoConstraints = false
        srv.isHidden = true
        return srv
    }()

    private var mTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search For Store Item"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    public var menuImage: UIImage? {
        didSet {
            if let menuImage = self.menuImage {
                if currentBarButtonState == .normal {
                    self.barButton.setImage(menuImage, for: .normal)
                }
            }
        }
    }

    public var backImage: UIImage? {
        didSet {
            if let backImage = self.backImage {
                if currentBarButtonState == .searching {
                    self.barButton.setImage(backImage, for: .normal)
                }
            }
        }
    }

    public var closeImage: UIImage? {
        didSet {
            if let closeImage = self.closeImage {
                self.closeButton.setImage(closeImage, for: .normal)
            }
        }
    }

    private var barButton: UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var closeButton: UIButton = {
        let btn = UIButton()
        btn.isEnabled = false
        if let empty = UIImage(named: "empty") {
            btn.setImage(empty, for: .disabled)
        }
        btn.imageView?.contentMode = .scaleAspectFit
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    public var borderColor: UIColor? {
        get {
            guard let color = self.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    public var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }

    public var borderCornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }

    public var searchDelay: Double = 0.2

    public var searchResultBackground: UIColor? {
        didSet {
            self.searchResultView.backgroundColor = searchResultBackground
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.config()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.config()
    }

    override public func layoutSubviews() {
        if self.superview != nil {
            self.superview!.bringSubviewToFront(self)
            self.layoutSearchResultView(self.superview!)
            self.searchResultView.tableViewTopOffset = self.frame.origin.y + self.frame.height + 10
        }
    }

    private func viewDefaultConfig() {
        self.borderColor = .black
        self.borderWidth = 0.5
        self.borderCornerRadius = 10
        self.backgroundColor = .white
        self.searchResultBackground = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.9)
        self.menuImage = SirlBundleHelper.getResourceImage(name: "menu_icon")
        self.backImage = SirlBundleHelper.getResourceImage(name: "back_arrow_icon")
        self.closeImage = SirlBundleHelper.getResourceImage(name: "close_icon")
    }

    private func layoutSearchResultView(_ superView: UIView) {
            superView.insertSubview(self.searchResultView, belowSubview: self)
            self.searchResultView.leftAnchor.constraint(equalTo: superView.leftAnchor).isActive = true
            self.searchResultView.rightAnchor.constraint(equalTo: superView.rightAnchor).isActive = true
            self.searchResultView.topAnchor.constraint(equalTo: superView.topAnchor).isActive = true
            self.searchResultView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
    }

    private func layoutConfig() {
        self.addSubview(barButton)
        self.addSubview(closeButton)
        self.addSubview(mTextField)
        self.barButton.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.barButton.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.barButton.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10).isActive = true
        self.barButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.closeButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.closeButton.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        self.closeButton.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10).isActive = true
        self.closeButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.mTextField.leftAnchor.constraint(equalTo: self.barButton.rightAnchor).isActive = true
        self.mTextField.rightAnchor.constraint(equalTo: self.closeButton.leftAnchor).isActive = true
        self.mTextField.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10).isActive = true
        self.mTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    private func config() {
        self.viewDefaultConfig()
        self.layoutConfig()
        self.searchResultView.delegate = self
        self.mTextField.delegate = self
        self.mTextField.addTarget(self, action: #selector(textFieldDidChangeContent), for: .editingChanged)
        self.barButton.addTarget(self, action: #selector(barBtnPress), for: .touchUpInside)
        self.closeButton.addTarget(self, action: #selector(closeBtnPress), for: .touchUpInside)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.searchResultView.keyboardHeight = keyboardRectangle.height
        }
    }

    @objc func keyboardWillHide() {
        self.searchResultView.keyboardHeight = 0
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setResultViewHidden(false)
        self.currentBarButtonState = .searching
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.setResultViewHidden(true)
        buttonTimer?.invalidate()
        buttonTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
            self.currentBarButtonState = .normal
        })
    }

    @objc public func textFieldDidChangeContent() {
        self.searchDelayTimer?.invalidate()
        searchResultView.searchResult?.removeAll()
        guard let mlID = self.mlID,
              let searchWord = mTextField.text?.trimmingCharacters(in: .whitespaces),
                searchWord.count > 2 else {
                    os_log("Search Conditions are not Satisfied", log: self.mLog, type: .debug)
                    return
                    }
        self.searchDelayTimer = Timer.scheduledTimer(
            withTimeInterval: searchDelay,
            repeats: false,
            block: { (_) in
                os_log("Sending Search Word: %@", log: self.mLog, type: .debug, searchWord)
                self.elog?.retailEvent(type: .search, content: searchWord)
                self.apiClient.send(
                    GetRelaventStoreItems(partialText: searchWord, mlId: Int(mlID))
                    ) { (res) in
                        os_log("Receive Search Word: %@", log: self.mLog, type: .debug, searchWord)
                        switch res {
                        case .success(let result):
                            self.searchResultView.searchResult = result
                        case .failure(let error):
                            os_log("Unable tp find search result %@", log: self.mLog, type: .error, error.localizedDescription)
                        }
                }
        })
    }

    private func setResultViewHidden(_ isHidden: Bool) {
        UIView.transition(with: self.searchResultView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.searchResultView.isHidden = isHidden
        }, completion: nil)
    }

    @objc private func barBtnPress() {
        switch currentBarButtonState {
        case .normal:
            self.delegate?.didPressSearchBarButton()
        case .searching:
            mTextField.text = currentProduct?.product?.name
            if mTextField.text == ""{
                self.searchResultView.searchResult = []
            }
            self.mTextField.endEditing(true)
        }

    }

    @objc private func closeBtnPress() {
        self.clearSearchBar()
    }

    public func clearSearchBar() {
        self.currentProduct = nil
        self.mTextField.text = ""
    }

    func didSelectProduct(product: StoreProduct) {
        self.currentProduct = product
        mTextField.endEditing(true)
    }

    public func reportIncorrectDestination(prodcutID: String) {
        elog?.retailEvent(type: .missingProduct, content: prodcutID)
    }
}
