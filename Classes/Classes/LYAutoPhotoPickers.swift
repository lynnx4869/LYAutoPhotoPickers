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

public class LYAutoPhotoPickers {
    
    public var type: LYAutoPhotoType = .camera
    public var isRateTailor: Bool = false
    public var tailoringRate: Double = 0.0
    public var maxSelects: Int = 1
    public var block: (Bool, [UIImage]?)->Void = {_,_  in }
    public var qrBlock: ()->Void = { }
    
    public init() {}
    
    public func showPhoto(in pvc: UIViewController) {
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
        
        return aec
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
            vc = qc
            break
        }
        
        return vc
    }
    
}
