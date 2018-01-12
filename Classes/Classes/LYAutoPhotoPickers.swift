//
//  LYAutoPhotoPickers.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/27.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos

public enum LYAutoPhotoType {
    case camera
    case album
    case qrcode
}

open class LYAutoPhoto {
    open var image: UIImage!
    open var asset: PHAsset!
    
    public init(_ image: UIImage!, _ asset: PHAsset!) {
        self.image = image
        self.asset = asset
    }
}

public typealias LYAutoCallback = (Bool, [LYAutoPhoto]?) -> Void
public typealias LYAutoQRCallback = (String?) -> Void

open class LYAutoPhotoPickers {
    
    open var type: LYAutoPhotoType = .camera
    open var isRateTailor: Bool = false
    open var tailoringRate: Double = 0.0
    open var maxSelects: Int = 1
    open var block: LYAutoCallback = { _,_  in }
    open var qrBlock: LYAutoQRCallback = { _  in }
    
    public init() {}
    
    open func showPhoto(in pvc: UIViewController) {
        checkPhotoAuth { (vc) in
            DispatchQueue.main.async {
                pvc.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func checkPhotoAuth(authBlock: @escaping ((_: UIViewController)->Void)) {
        if type == .camera || type == .qrcode {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                              completionHandler:
                    { (granted) in
                        if granted {
                            authBlock(self.getDefaultController())
                        } else {
                            authBlock(self.getErrorController())
                        }
                })
            } else if authStatus == .denied {
                authBlock(getErrorController())
            } else if authStatus == .authorized {
                authBlock(getDefaultController())
            }
        } else if type == .album {
            let authStatus = PHPhotoLibrary.authorizationStatus()
            
            if authStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .denied {
                        authBlock(self.getErrorController())
                    } else if status == .authorized {
                        authBlock(self.getDefaultController())
                    }
                })
            } else if authStatus == .denied {
                authBlock(getErrorController())
            } else if authStatus == .authorized {
                authBlock(getDefaultController())
            }
        }
    }
    
    fileprivate func getErrorController() -> UIViewController {
        let aec = LYAutoAuthErrorController(nibName: "LYAutoAuthErrorController", bundle: Bundle(for: LYAutoPhotoPickers.self))
        aec.type = type
        
        let nav = UINavigationController(rootViewController: aec)
        nav.navigationBar.isTranslucent = false
        
        return nav
    }
    
    fileprivate func getDefaultController() -> UIViewController {
        var vc: UIViewController!
        
        switch type {
        case .camera:
            let cuvc = LYAutoCameraController()
            cuvc.isRateTailor = isRateTailor
            cuvc.tailoringRate = tailoringRate
            cuvc.block = block
            vc = cuvc
            break
        case .album:
            let avc = LYAutoAlbumsController()
            avc.isRateTailor = isRateTailor
            avc.tailoringRate = tailoringRate
            avc.block = block
            avc.maxSelects = maxSelects
            
            let nav = UINavigationController(rootViewController: avc)
            nav.navigationBar.isTranslucent = false
            vc = nav
            break
        case .qrcode:
            let qc = LYAutoQRCodeController()
            qc.qrBlock = qrBlock
            
            let nav = UINavigationController(rootViewController: qc)
            nav.navigationBar.tintColor = .white
            nav.navigationBar.barStyle = .black
            nav.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            nav.navigationBar.shadowImage = UIImage()
            vc = nav
            break
        }
        
        return vc
    }
    
}
