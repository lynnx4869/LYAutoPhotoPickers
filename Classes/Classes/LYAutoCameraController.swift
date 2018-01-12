//
//  LYAutoCameraController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/28.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos
import LYAutoUtils
import TOCropViewController

class LYAutoCameraController: LYAutoPhotoBasicController, TOCropViewControllerDelegate {
    
    fileprivate var cameraView: UIView!
    fileprivate var photoView: UIView!
    
    fileprivate var device: AVCaptureDevice!
    fileprivate var input: AVCaptureDeviceInput!
    fileprivate var imageOutput = AVCaptureStillImageOutput()
    fileprivate var session = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    fileprivate var displayImage: UIImageView!
    
    fileprivate var image: UIImage? {
        didSet {
            if self.image != nil {
                displayImage.image = image
                
                cameraView.isHidden = true
                photoView.isHidden = false
            } else {
                displayImage.image = nil
                
                cameraView.isHidden = false
                photoView.isHidden = true
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    [weak self] in
                    self?.session.startRunning()
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cameraView = UIView()
        cameraView.backgroundColor = .white
        view.addSubview(cameraView)
        
        photoView = UIView()
        photoView.backgroundColor = .white
        view.addSubview(photoView)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        cameraView.edge(to: view, padding: padding)
        photoView.edge(to: view, padding: padding)
        
        photoView.isHidden = true
        
        cameraInit()
        initCameraBtns()
        initDisplayImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("LY Auto Camera alloc ...")
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
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
        previewLayer.frame = CGRect(x: 0, y: 0, width: LyConsts.ScreenWidth, height: LyConsts.ScreenHeight)
        cameraView.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
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
    }
    
    fileprivate func initCameraBtns() {
        let touchView = UIView()
        touchView.backgroundColor = .clear
        cameraView.addSubview(touchView)
        
        touchView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(_:))))
        
        touchView.edge(to: cameraView, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(named: "ly_cross", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeCamera(_:)), for: .touchUpInside)
        cameraView.addSubview(closeBtn)
        
        closeBtn.top(to: cameraView, attribute: .top, constant: 15)
        closeBtn.left(to: cameraView, attribute: .left, constant: 10)
        closeBtn.width(to: cameraView, constant: 40)
        closeBtn.height(to: cameraView, constant: 40)

        let takePhotoBtn = UIButton(type: .custom)
        takePhotoBtn.setImage(UIImage(named: "ly_round", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        takePhotoBtn.addTarget(self, action: #selector(takePhoto(_:)), for: .touchUpInside)
        cameraView.addSubview(takePhotoBtn)
        
        takePhotoBtn.bottom(to: cameraView, attribute: .bottom, constant: -10)
        takePhotoBtn.centerX(to: cameraView, attribute: .centerX)
        takePhotoBtn.width(to: cameraView, constant: 100)
        takePhotoBtn.height(to: cameraView, constant: 100)
        
        let flashChangeBtn = UIButton(type: .custom)
        flashChangeBtn.setImage(UIImage(named: "ly_flash-auto", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        flashChangeBtn.addTarget(self, action: #selector(changeFlash(_:)), for: .touchUpInside)
        cameraView.addSubview(flashChangeBtn)
        
        flashChangeBtn.top(to: cameraView, attribute: .top, constant: 15)
        flashChangeBtn.right(to: cameraView, attribute: .right, constant: -60)
        flashChangeBtn.width(to: cameraView, constant: 40)
        flashChangeBtn.height(to: cameraView, constant: 40)
        
        let cameraChangeBtn = UIButton(type: .custom)
        cameraChangeBtn.setImage(UIImage(named: "ly_camera-front-on", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        cameraChangeBtn.addTarget(self, action: #selector(changeCamera(_:)), for: .touchUpInside)
        cameraView.addSubview(cameraChangeBtn)
        
        cameraChangeBtn.top(to: cameraView, attribute: .top, constant: 15)
        cameraChangeBtn.right(to: cameraView, attribute: .right, constant: -10)
        cameraChangeBtn.width(to: cameraView, constant: 40)
        cameraChangeBtn.height(to: cameraView, constant: 40)
    }
    
    fileprivate func initDisplayImage() {
        displayImage = UIImageView()
        photoView.addSubview(displayImage)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        displayImage.edge(to: photoView, padding: padding)

        let takePhotoAgainBtn = UIButton(type: .custom)
        takePhotoAgainBtn.setTitle("重拍", for: .normal)
        takePhotoAgainBtn.addTarget(self, action: #selector(takePhotoAgain(_:)), for: .touchUpInside)
        photoView.addSubview(takePhotoAgainBtn)
        
        takePhotoAgainBtn.top(to: photoView, attribute: .top, constant: 15)
        takePhotoAgainBtn.left(to: photoView, attribute: .left, constant: 10)
        takePhotoAgainBtn.width(to: photoView, constant: 40)
        takePhotoAgainBtn.height(to: photoView, constant: 20)
        
        let cutBtn = UIButton()
        cutBtn.setImage(UIImage(named: "ly_cut", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        cutBtn.addTarget(self, action: #selector(cutPhoto(_:)), for: .touchUpInside)
        photoView.addSubview(cutBtn)
        
        cutBtn.bottom(to: photoView, attribute: .bottom, constant: -10)
        cutBtn.right(to: photoView, attribute: .right, constant: -60)
        cutBtn.width(to: photoView, constant: 40)
        cutBtn.height(to: photoView, constant: 40)
        
        let sureBtn = UIButton()
        sureBtn.setImage(UIImage(named: "ly_sure", in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil), for: .normal)
        sureBtn.addTarget(self, action: #selector(surePhoto(_:)), for: .touchUpInside)
        photoView.addSubview(sureBtn)
        
        sureBtn.bottom(to: photoView, attribute: .bottom, constant: -10)
        sureBtn.right(to: photoView, attribute: .right, constant: -10)
        sureBtn.width(to: photoView, constant: 40)
        sureBtn.height(to: photoView, constant: 40)
        
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
    
    @objc fileprivate func closeCamera(_ btn: UIButton) {
        block(false, nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func changeCamera(_ btn: UIButton) {
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
    
    @objc fileprivate func changeFlash(_ btn: UIButton) {
        do {
            var newImageName: String!
            var newFlashMode: AVCaptureDevice.FlashMode!
            
            if device.flashMode == .auto {
                newImageName = "ly_flash-on"
                newFlashMode = .on
            } else if device.flashMode == .on {
                newImageName = "ly_flash-off"
                newFlashMode = .off
            } else {
                newImageName = "ly_flash-auto"
                newFlashMode = .auto
            }
            
            btn.setImage(UIImage(named: newImageName,
                                 in: Bundle(for: LYAutoPhotoPickers.self), compatibleWith: nil),
                         for: .normal)
            
            try device.lockForConfiguration()
            device.flashMode = newFlashMode
            device.unlockForConfiguration()
        } catch {
            debugPrint(error)
        }
    }
    
    fileprivate var initialPinchZoom: CGFloat = 0
    
    @objc fileprivate func pinchImage(_ pinch: UIPinchGestureRecognizer) {
        do {
            if pinch.state == .began {
                try device.lockForConfiguration()
                initialPinchZoom = device.videoZoomFactor
            }
            
            if pinch.state == .changed {
//                device.videoZoomFactor = pinch.scale / pinch.scale
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
        } catch {
            debugPrint(error)
        }
    }
    
    @objc fileprivate func takePhoto(_ btn: UIButton) {
        let connect = imageOutput.connection(with: AVMediaType.video)
        if connect == nil {
            debugPrint("take photo error ...")
            return
        } else {
            imageOutput.captureStillImageAsynchronously(from: connect!,
                                                        completionHandler:
            { [weak self] (imageDataSampleBuffer, error) in
                if imageDataSampleBuffer == nil {
                    debugPrint("take photo error ...")
                    return
                }
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                let image = UIImage(data: imageData!, scale: 1.0)
                self?.image = image
                self?.session.stopRunning()
            })
        }
    }
    
    @objc fileprivate func takePhotoAgain(_ btn: UIButton) {
        image = nil
    }
    
    @objc fileprivate func cutPhoto(_ btn: UIButton) {
        let tcvc = TOCropViewController(image: image!)
        tcvc.delegate = self
        tcvc.rotateClockwiseButtonHidden = false
        if isRateTailor {
            tcvc.customAspectRatio = CGSize(width: tailoringRate, height: 1.0)
            tcvc.aspectRatioLockEnabled = true
            tcvc.resetAspectRatioEnabled = false
            tcvc.aspectRatioLockEnabled = true
        }
        
        present(UINavigationController(rootViewController: tcvc),
                animated: true,
                completion: nil)
    }
    
    @objc fileprivate func surePhoto(_ btn: UIButton) {
        block(true, [LYAutoPhoto(image, nil)])
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TOCropViewControllerDelegate
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.image = nil
        block(true, [LYAutoPhoto(image, nil)])

        cropViewController.dismiss(animated: false) { 
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
}
