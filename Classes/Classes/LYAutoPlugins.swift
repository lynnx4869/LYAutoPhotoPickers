//
//  LYAutoPlugins.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2018/6/22.
//  Copyright © 2018年 lyning. All rights reserved.
//

import UIKit
import Photos
import CoreMotion
import CropViewController

class LYAutoCameraView: UIView {
    
    weak var cc: LYAutoCameraController!
    
    fileprivate var device: AVCaptureDevice!
    fileprivate var input: AVCaptureDeviceInput!
    fileprivate var imageOutput = AVCaptureStillImageOutput()
    fileprivate var session = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    fileprivate let manager = CMMotionManager()
    fileprivate var orientation = UIDeviceOrientation.portrait
    
    override func didMoveToSuperview() {
        cameraInit()
        
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchPhoto(_:))))
        
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.1
            manager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
                if let motion = motion {
                    let x = motion.gravity.x
                    let y = motion.gravity.y
                    
                    if fabs(y) >= fabs(x) {
                        if y >= 0 {
                            self?.orientation = UIDeviceOrientation.portraitUpsideDown
                        } else {
                            self?.orientation = UIDeviceOrientation.portrait
                        }
                    } else {
                        if x >= 0 {
                            self?.orientation = UIDeviceOrientation.landscapeRight
                        } else {
                            self?.orientation = UIDeviceOrientation.landscapeLeft
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        manager.stopDeviceMotionUpdates()
        debugPrint("LYAutoCameraView deinit ...")
    }
    
    fileprivate func cameraInit() {
        device = cameraOfPosition(position: .back)
        do {
            input = try AVCaptureDeviceInput(device: device)
            session.sessionPreset = .hd1920x1080
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            debugPrint(error)
        }
        
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
        layer.insertSublayer(previewLayer, at: 0)
                
        do {
            try device.lockForConfiguration()
            
            if device.isFlashModeSupported(.auto) {
                device.flashMode = .auto
            }
            
            if device.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                device.whiteBalanceMode = .autoWhiteBalance
            }
            
            device.unlockForConfiguration()
        } catch {
            debugPrint(error)
        }
        
        startSession()
    }
    
    func startSession() {
        session.startRunning()
    }
    
    @IBAction func closeCamera(_ sender: UIButton) {
        if session.isRunning {
            session.stopRunning()
        }
        cc.block(nil)
        cc.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        if let connect = imageOutput.connection(with: AVMediaType.video) {
            imageOutput
                .captureStillImageAsynchronously(from: connect,
                                                 completionHandler:
                    { [weak self] (buff, error) in
                        if error == nil {
                            if let imageDataSampleBuffer = buff,
                                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) {
                                let image = UIImage(data: imageData, scale: 1.0)?
                                    .fix((self?.orientation)!, (self?.input.device.position)!)?.fixOrientation()
                                self?.cc.image = image
                                self?.session.stopRunning()
                            }
                        } else {
                            debugPrint("take photo error ...")
                        }
                })
        } else {
            debugPrint("take photo error ...")
        }
    }
    
    @IBAction func changeCamera(_ sender: UIButton) {
        let cameraCount = AVCaptureDevice.devices(for: .video).count
        if cameraCount > 1 {
            var newDevice: AVCaptureDevice!
            if input.device.position == .front {
                newDevice = cameraOfPosition(position: .back)
            } else {
                newDevice = cameraOfPosition(position: .front)
            }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                session.beginConfiguration()
                session.removeInput(input)
                if session.canAddInput(newInput) {
                    session.addInput(newInput)
                    input = newInput
                } else {
                    session.addInput(input)
                }
                session.commitConfiguration()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    fileprivate var initialPinchZoom: CGFloat = 0
    @objc fileprivate func pinchPhoto(_ pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            do {
                try device.lockForConfiguration()
                initialPinchZoom = device.videoZoomFactor
            } catch {
                debugPrint(error)
            }
        }
        
        if pinch.state == .changed {
            var zoomFactor: CGFloat = 0
            let scale = pinch.scale
            if scale < 1.0 {
                zoomFactor = initialPinchZoom - pow(device.activeFormat.videoMaxZoomFactor, 1.0-scale)
            } else {
                zoomFactor = initialPinchZoom + pow(device.activeFormat.videoMaxZoomFactor, (scale-1.0)/2.0)
            }
            zoomFactor = min(10.0, zoomFactor)
            zoomFactor = max(1.0, zoomFactor)
            device.videoZoomFactor = zoomFactor
        }
        
        if pinch.state == .ended || pinch.state == .cancelled {
            device.unlockForConfiguration()
        }
    }
    
    fileprivate func cameraOfPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
}

class LYAutoPhotoView: UIView {
    
    weak var cc: LYAutoCameraController!
    
    deinit {
        debugPrint("LYAutoPhotoView deinit ...")
    }
    
    @IBOutlet weak var displayImage: UIImageView!
    
    @IBAction func takePhotoAgain(_ sender: UIButton) {
        cc.image = nil
    }
    
    @IBAction func cutPhoto(_ sender: UIButton) {
        if let tm = cc.image {
            let cvc = CropViewController(image: tm)
            cvc.delegate = self
            cvc.rotateClockwiseButtonHidden = false
            if cc.isRateTailor {
                cvc.customAspectRatio = CGSize(width: cc.tailoringRate, height: 1.0)
                cvc.aspectRatioLockEnabled = true
                cvc.resetAspectRatioEnabled = false
                cvc.aspectRatioLockEnabled = true
            }
            
            cc.present(UINavigationController(rootViewController: cvc),
                       animated: true, completion: nil)
        }
    }
    
    @IBAction func surePhoto(_ sender: UIButton) {
        let photo = LYAutoPhoto()
        photo.image = cc.image
        cc.block([photo])
        cc.dismiss(animated: true, completion: nil)
    }
    
}

extension LYAutoPhotoView: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: false, completion: nil)
        cc.image = image
    }
    
}

