//
//  LYAutoQRCodeController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/7/3.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos
import LYAutoUtils

class LYAutoQRCodeController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    fileprivate var session = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scanQRCode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func scanQRCode() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input = try? AVCaptureDeviceInput(device: device)
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        let width = LyConsts.ScreenWidth - 60
        
        output.rectForMetadataOutputRect(ofInterest: CGRect(x: 30, y: 150, width: width, height: width))
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange,
//            object: nil,
//            queue: OperationQueue.current) { (noti) in
//                output.metadataOutputRectOfInterest(for: (self.previewLayer?.metadataOutputRectOfInterest(for: CGRect(x: 30, y: 150, width: width, height: width)))!)
//        }
    
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.bounds
        view.layer.addSublayer(previewLayer!)

        view.addSubview(getShadowBg(frame: CGRect(x: 0, y: 0, width: width+30, height: 150)))
        view.addSubview(getShadowBg(frame: CGRect(x: width+30, y: 0, width: 30, height: width+150)))
        view.addSubview(getShadowBg(frame: CGRect(x: 0, y: 150, width: 30, height: LyConsts.ScreenHeight-150)))
        view.addSubview(getShadowBg(frame: CGRect(x: 30, y: 150+width, width: width+30, height: LyConsts.ScreenHeight-150-width)))
        
        session.startRunning()
    }
    
    fileprivate func getShadowBg(frame: CGRect) -> UIView {
        let view = UIView(frame: frame)
        
        view.backgroundColor = UIColor.color(hex: 0x000000, alpha: 0.7)
        
        return view
    }
    
    //MARK: - AVCaptureMetadataOutputObjectsDelegate
    internal func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            session.stopRunning()
            
            let object = metadataObjects.last as? AVMetadataMachineReadableCodeObject
            
            print(String(describing: object?.stringValue))
        }
    }

}
