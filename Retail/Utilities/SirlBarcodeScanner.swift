//
//  SirlBarcodeScann/Users/weicai/Documents/Sirl/IOS/pips-ios-indoor/SIRL_iOS_SDKer.swift
//  SirlSDK
//
//  Created by Wei Cai on 6/8/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import UIKit
import AVFoundation
import os.log
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public protocol SirlBarCodeScannerDelegate: class {
    func didFoundBarCode(barCodeType: barCodeType, value: String)
}

@IBDesignable
@available(iOS 10.0, *)
open class SirlBarCodeScanner: UIView, AVCaptureMetadataOutputObjectsDelegate {

    let mLog = OSLog(subsystem: "com.sirl.barcode.scanner", category: "Dynamic_Product_Replacement")
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    var accuracyCheckNumber: Int = 3

    private var curCodeType: barCodeType = .code128

    private var numberOfTry: Int = 0 {
        didSet {
            if numberOfTry >= accuracyCheckNumber {
                delegate?.didFoundBarCode(barCodeType: self.curCodeType, value: scanResult)
                numberOfTry = 0
            }
        }
    }

    private var scanResult: String = "" {
        didSet {
            if oldValue == scanResult {
                numberOfTry += 1
            }
        }
    }

    public weak var delegate: SirlBarCodeScannerDelegate?

    @IBInspectable public var scanFramColor: UIColor = UIColor.green {
        didSet {
            barCodeFrameView?.layer.borderColor = scanFramColor.cgColor
            layoutIfNeeded()
        }
    }

    private let supportedCodeFormat = [AVMetadataObject.ObjectType.qr,
                                       AVMetadataObject.ObjectType.ean13,
                                       AVMetadataObject.ObjectType.upce,
                                       AVMetadataObject.ObjectType.code39,
                                       AVMetadataObject.ObjectType.code39Mod43,
                                       AVMetadataObject.ObjectType.code93,
                                       AVMetadataObject.ObjectType.code128,
                                       AVMetadataObject.ObjectType.ean8,
                                       AVMetadataObject.ObjectType.aztec,
                                       AVMetadataObject.ObjectType.pdf417,
                                       AVMetadataObject.ObjectType.itf14,
                                       AVMetadataObject.ObjectType.dataMatrix,
                                       AVMetadataObject.ObjectType.interleaved2of5]

    private let barCodeTypeDic = [AVMetadataObject.ObjectType.qr: barCodeType.qr,
                                  AVMetadataObject.ObjectType.ean13: barCodeType.upca,
                                  AVMetadataObject.ObjectType.upce: barCodeType.upce,
                                  AVMetadataObject.ObjectType.code39: barCodeType.code39,
                                  AVMetadataObject.ObjectType.code39Mod43: barCodeType.code39Mod43,
                                  AVMetadataObject.ObjectType.code93: barCodeType.code93,
                                  AVMetadataObject.ObjectType.code128: barCodeType.code128,
                                  AVMetadataObject.ObjectType.ean8: barCodeType.ean8,
                                  AVMetadataObject.ObjectType.aztec: barCodeType.aztec,
                                  AVMetadataObject.ObjectType.pdf417: barCodeType.pdf417,
                                  AVMetadataObject.ObjectType.itf14: barCodeType.itf14,
                                  AVMetadataObject.ObjectType.dataMatrix: barCodeType.dataMatrix,
                                  AVMetadataObject.ObjectType.interleaved2of5: barCodeType.interleaved2of5]

    override public init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = self.layer.bounds

    }

    public func config() {
        captureSession = AVCaptureSession()
        if #available(iOS 10.2, *) {
            let deviceDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

            guard let captureDevice = deviceDiscoverSession.devices.first else {
                os_log("Failed to get the camera", log: mLog, type: .error)
                return
            }
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                let captureMetadataOutPut = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutPut)
                captureMetadataOutPut.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutPut.metadataObjectTypes = supportedCodeFormat
            } catch {
                os_log("%@", log: mLog, type: .error, error.localizedDescription)
                return
            }
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = self.layer.bounds
            self.layer.addSublayer(videoPreviewLayer!)
            barCodeFrameView = UIView()
            barCodeFrameView?.layer.borderColor = scanFramColor.cgColor
            barCodeFrameView?.layer.borderWidth = 2
            self.addSubview(barCodeFrameView!)
            self.bringSubviewToFront(barCodeFrameView!)
        }
    }

    public func startScan() {
        barCodeFrameView?.frame = CGRect.zero
        captureSession.startRunning()
    }

    public func stopScan() {
        captureSession.stopRunning()
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeFormat.contains(metadataObj.type) {
            let barCodeObj = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObj!.bounds
            if let value = metadataObj.stringValue {
                self.curCodeType = barCodeTypeDic[metadataObj.type]!
                self.scanResult = value
            }
        }

    }

}
