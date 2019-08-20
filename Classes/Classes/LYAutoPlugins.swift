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

class LYAutoCameraView: UIView, AVCapturePhotoCaptureDelegate {
    
    weak var cc: LYAutoCameraController!
    
//    private var device: AVCaptureDevice!
//    private var input: AVCaptureDeviceInput!
    private lazy var session: AVCaptureSession = {
        return AVCaptureSession()
    }()
    private lazy var imageOutput: AVCapturePhotoOutput = {
        return AVCapturePhotoOutput()
    }()
//    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let manager = CMMotionManager()
    private var orientation = UIDeviceOrientation.portrait
    
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
    
    private func cameraInit() {
        if let device = cameraOfPosition(position: .back) {
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                session.sessionPreset = .hd1920x1080
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(imageOutput) {
                    session.addOutput(imageOutput)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds
        layer.insertSublayer(previewLayer, at: 0)
        
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
        let settings = AVCapturePhotoSettings()
        if imageOutput.supportedFlashModes.contains(.auto) {
            settings.flashMode = .auto
        }
        imageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func changeCamera(_ sender: UIButton) {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else {
            return
        }
        
        var position: AVCaptureDevice.Position = .back
        if input.device.position == .back {
            position = .front
        } else {
            position = .back
        }
        
        if let newDevice = cameraOfPosition(position: position) {
            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                session.beginConfiguration()
                session.removeInput(input)
                if session.canAddInput(newInput) {
                    session.addInput(newInput)
                } else {
                    session.addInput(input)
                }
                session.commitConfiguration()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    private var initialPinchZoom: CGFloat = 0
    @objc private func pinchPhoto(_ pinch: UIPinchGestureRecognizer) {
        guard let input = session.inputs.first as? AVCaptureDeviceInput else {
            return
        }
        
        if pinch.state == .began {
            do {
                try input.device.lockForConfiguration()
                initialPinchZoom = input.device.videoZoomFactor
            } catch {
                debugPrint(error)
            }
        }
        
        if pinch.state == .changed {
            var zoomFactor: CGFloat = 0
            let scale = pinch.scale
            if scale < 1.0 {
                zoomFactor = initialPinchZoom - pow(input.device.activeFormat.videoMaxZoomFactor, 1.0-scale)
            } else {
                zoomFactor = initialPinchZoom + pow(input.device.activeFormat.videoMaxZoomFactor, (scale-1.0)/2.0)
            }
            zoomFactor = min(10.0, zoomFactor)
            zoomFactor = max(1.0, zoomFactor)
            input.device.videoZoomFactor = zoomFactor
        }
        
        if pinch.state == .ended || pinch.state == .cancelled {
            input.device.unlockForConfiguration()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let _ = error {
            debugPrint("take photo error ...")
        } else {
            if let input = session.inputs.first as? AVCaptureDeviceInput,
                let photoSampleBuffer = photoSampleBuffer,
                let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
                let image = UIImage(data: imageData, scale: 1.0)?.fix(orientation, input.device.position)?.fixOrientation()
                self.cc.image = image
                session.stopRunning()
            }
        }
    }
    
    private func cameraOfPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices
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

