//
//  LYAutoQRCodeController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/7/3.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import AVFoundation
import LYAutoUtils

class LYAutoQRCodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrBlock: LYAutoQRCallback = { _ in }
    
    fileprivate var session: AVCaptureSession!
    fileprivate var output: AVCaptureMetadataOutput!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = "二维码/条形码"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goBack(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "相册", style: .done, target: self, action: #selector(scanImage(_:)))
        
        scanQRCode()
        initViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("QRCode Controller Deinit ...")
    }
    
    @objc fileprivate func goBack(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func scanImage(_ sender: UIBarButtonItem) {
        showPickers(type: .album, callback: { [weak self] photos in
            if let photo = photos?.first,
                let ciimage = photo.image.ciImage,
                let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                          context: nil,
                                          options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
                let features = detector.features(in: ciimage)
                if let f = features.first,
                    let feature = f as? CIQRCodeFeature {
                    self?.qrBlock(feature.messageString)
                } else {
                    self?.qrBlock(nil)
                }
            }
            
            DispatchQueue.main.async {
                self?.navigationController?.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    fileprivate func scanQRCode() {
        session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080

        do {
            if let device = AVCaptureDevice.default(for: .video) {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            }
        } catch {
            debugPrint(error)
        }
        
        output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.code128]
    
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
    }
    
    fileprivate func initViews() {
        if let scanView = Bundle(for: LYAutoPhotoPickers.self).loadNibNamed("LYAutoQRScanView", owner: nil, options: nil)?.first as? LYAutoQRScanView {
            let width = LyConsts.ScreenWidth * 0.7
            
            scanView.center = view.center
            scanView.bounds = CGRect(x: 0, y: 0, width: width, height: width)
            view.addSubview(scanView)
            
            let path = UIBezierPath(rect: view.bounds)
            path.append(UIBezierPath(rect: scanView.frame))
            path.usesEvenOddFillRule = true
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.frame = view.bounds
            shapeLayer.fillColor = UIColor.black.cgColor
            shapeLayer.opacity = 0.6
            shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
            view.layer.addSublayer(shapeLayer)
            
            output.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanView.frame)
        }
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            session.stopRunning()
            
            let object = metadataObjects.last as? AVMetadataMachineReadableCodeObject
            qrBlock(object?.stringValue)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }

}
