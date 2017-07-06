//
//  LYAutoCameraController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/28.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import SnapKit
import Photos
import LYAutoUtils
import TOCropViewController

class LYAutoCameraController: LYAutoPhotoBasicController, TOCropViewControllerDelegate {
    
    fileprivate let cameraView = UIView()
    fileprivate let photoView = UIView()
    
    fileprivate var device: AVCaptureDevice?
    fileprivate var input: AVCaptureDeviceInput?
    fileprivate var imageOutput = AVCaptureStillImageOutput()
    fileprivate var session = AVCaptureSession()
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    
    fileprivate var displayImage = UIImageView()
    
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
        
        cameraView.backgroundColor = .white
        view.addSubview(cameraView)
        
        photoView.backgroundColor = .white
        view.addSubview(photoView)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        cameraView.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(padding)
        }
        
        photoView.snp.makeConstraints { (make) in
            make.edges.equalTo(view).inset(padding)
        }
        
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
        print("LY Auto Camera alloc ...")
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    fileprivate func cameraInit() {
        device = cameraOfPosition(position: .back)
        input = try? AVCaptureDeviceInput(device: device)
        
        session.sessionPreset = AVCaptureSessionPreset1920x1080
        
        if session.canAddInput(input) {
            session.addInput(input!)
        }
        
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = CGRect(x: 0, y: 0, width: LyConsts.ScreenWidth, height: LyConsts.ScreenHeight)
        cameraView.layer.addSublayer(previewLayer!)
        
        session.startRunning()
        
        if ((try? device?.lockForConfiguration()) != nil) {
            if (device?.isFlashModeSupported(.off))! {
                device?.flashMode = .off
            }
            
            if (device?.isWhiteBalanceModeSupported(.autoWhiteBalance))! {
                device?.whiteBalanceMode = .autoWhiteBalance
            }
            
            device?.unlockForConfiguration()
        }
        
    }
    
    fileprivate func initCameraBtns() {
        
        let touchView = UIView()
        touchView.backgroundColor = .clear
        cameraView.addSubview(touchView)
        
        touchView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(pinch:))))
        
        touchView.snp.makeConstraints { (make) in
            make.edges.equalTo(cameraView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        let closeBtn = UIButton(type: .custom)
        closeBtn.setImage(UIImage(named: "ly_cross"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeCamera(btn:)), for: .touchUpInside)
        cameraView.addSubview(closeBtn)
        
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cameraView.snp.top).offset(15)
            make.left.equalTo(cameraView.snp.left).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        let takePhotoBtn = UIButton(type: .custom)
        takePhotoBtn.setImage(UIImage(named: "ly_round"), for: .normal)
        takePhotoBtn.addTarget(self, action: #selector(takePhoto(btn:)), for: .touchUpInside)
        cameraView.addSubview(takePhotoBtn)
        
        takePhotoBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(cameraView.snp.bottom).offset(-10)
            make.centerX.equalTo(cameraView.snp.centerX)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        let flashChangeBtn = UIButton(type: .custom)
        flashChangeBtn.setImage(UIImage(named: "ly_flash-off"), for: .normal)
        flashChangeBtn.addTarget(self, action: #selector(changeFlash(btn:)), for: .touchUpInside)
        cameraView.addSubview(flashChangeBtn)
        
        flashChangeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cameraView.snp.top).offset(15)
            make.right.equalTo(cameraView.snp.right).offset(-60)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        let cameraChangeBtn = UIButton(type: .custom)
        cameraChangeBtn.setImage(UIImage(named: "ly_camera-front-on"), for: .normal)
        cameraChangeBtn.addTarget(self, action: #selector(changeCamera(btn:)), for: .touchUpInside)
        cameraView.addSubview(cameraChangeBtn)
        
        cameraChangeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cameraView.snp.top).offset(15)
            make.right.equalTo(cameraView.snp.right).offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    fileprivate func initDisplayImage() {
        photoView.addSubview(displayImage)
        
        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        displayImage.snp.makeConstraints { (make) in
            make.edges.equalTo(photoView).inset(padding)
        }

        let takePhotoAgainBtn = UIButton(type: .custom)
        takePhotoAgainBtn.setTitle("重拍", for: .normal)
        takePhotoAgainBtn.addTarget(self, action: #selector(takePhotoAgain(btn:)), for: .touchUpInside)
        photoView.addSubview(takePhotoAgainBtn)

        takePhotoAgainBtn.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.top).offset(15)
            make.left.equalTo(photoView.snp.left).offset(10)
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
        
        let cutBtn = UIButton()
        cutBtn.setImage(UIImage(named: "ly_cut"), for: .normal)
        cutBtn.addTarget(self, action: #selector(cutPhoto(btn:)), for: .touchUpInside)
        photoView.addSubview(cutBtn)
        
        cutBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(photoView.snp.bottom).offset(-10)
            make.right.equalTo(photoView.snp.right).offset(-60)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        let sureBtn = UIButton()
        sureBtn.setImage(UIImage(named: "ly_sure"), for: .normal)
        sureBtn.addTarget(self, action: #selector(surePhoto(btn:)), for: .touchUpInside)
        photoView.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(photoView.snp.bottom).offset(-10)
            make.right.equalTo(photoView.snp.right).offset(-10)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
    }
    
    fileprivate func cameraOfPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! [AVCaptureDevice]
        for device in devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    @objc fileprivate func closeCamera(btn: UIButton) {
        block!(false, nil)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func changeCamera(btn: UIButton) {
        let cameraCount = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count
        
        if cameraCount > 1 {
            var newDevice: AVCaptureDevice?
            
            let position = input?.device.position
            if position == .front {
                newDevice = cameraOfPosition(position: .back)
            } else {
                newDevice = cameraOfPosition(position: .front)
            }
            
            let newInput = try? AVCaptureDeviceInput(device: newDevice)
            if newInput != nil {
                session.beginConfiguration()
                session.removeInput(input)
                if session.canAddInput(newInput) {
                    session.addInput(newInput!)
                    input = newInput
                } else {
                    session.addInput(input)
                }
                session.commitConfiguration()
            }
        }
    }
    
    @objc fileprivate func changeFlash(btn: UIButton) {
        if device?.flashMode == .on {
            btn.setImage(UIImage(named: "ly_flash-off"), for: .normal)
            
            if (try? device?.lockForConfiguration()) != nil {
                device?.flashMode = .off
                device?.unlockForConfiguration()
            }
        } else {
            btn.setImage(UIImage(named: "ly_flash"), for: .normal)
            
            if (try? device?.lockForConfiguration()) != nil {
                device?.flashMode = .on
                device?.unlockForConfiguration()
            }
        }
    }
    
    var initialPinchZoom: CGFloat = 0
    
    @objc fileprivate func pinchImage(pinch: UIPinchGestureRecognizer) {
        if pinch.state == .began {
            try? device?.lockForConfiguration()
            initialPinchZoom = (device?.videoZoomFactor)!
        }
        
        if pinch.state == .changed {
            device?.videoZoomFactor = pinch.scale / pinch.scale
            var zoomFactor: CGFloat = 0
            let scale = pinch.scale
            if scale < 1.0 {
                zoomFactor = initialPinchZoom - CGFloat(pow(Double((device?.activeFormat.videoMaxZoomFactor)!), Double(1.0-scale)))
            } else {
                zoomFactor = initialPinchZoom + CGFloat(pow(Double((device?.activeFormat.videoMaxZoomFactor)!), Double((scale-1.0)/2.0)))
            }
            
            zoomFactor = min(10.0, zoomFactor)
            zoomFactor = max(1.0, zoomFactor)
            
            device?.videoZoomFactor = zoomFactor
        }
        
        if pinch.state == .ended || pinch.state == .cancelled {
            device?.unlockForConfiguration()
        }
    }
    
    @objc fileprivate func takePhoto(btn: UIButton) {
        let connect = imageOutput.connection(withMediaType: AVMediaTypeVideo)
        if connect == nil {
            print("take photo error ...")
            return
        } else {
            imageOutput.captureStillImageAsynchronously(from: connect,
                                                        completionHandler:
            { [weak self] (imageDataSampleBuffer, error) in
                if imageDataSampleBuffer == nil {
                    return
                }
                
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                let image = UIImage(data: imageData!, scale: 1.0)
                self?.image = image
                self?.session.stopRunning()
            })
        }
    }
    
    @objc fileprivate func takePhotoAgain(btn: UIButton) {
        image = nil
    }
    
    @objc fileprivate func cutPhoto(btn: UIButton) {
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
    
    @objc fileprivate func surePhoto(btn: UIButton) {
        block!(true, [image!])
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - TOCropViewControllerDelegate
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.image = nil
        block!(true, [image])
 
        cropViewController.dismiss(animated: false) { 
            [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
}
