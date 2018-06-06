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

open class LYAutoPhoto: NSObject {
    open var image: UIImage!
    open var tumImage: UIImage!
    open var asset: PHAsset!
}

public typealias LYAutoCallback = ([LYAutoPhoto]?) -> Void
public typealias LYAutoQRCallback = (String?) -> Void

public extension UIViewController {
    
    public func showPickers(type: LYAutoPhotoType = .camera,
                            maxSelects: Int = 1,
                            isRateTailor: Bool = false,
                            tailoringRate: Double = 0.0,
                            callback: @escaping LYAutoCallback = { _ in },
                            qr: @escaping LYAutoQRCallback = { _ in }) {
        let picker = LYAutoPhotoPickers()
        picker.checkPhotoAuth(type) { result in
            if result {
                switch type {
                case .camera:
                    let cuvc = LYAutoCameraController()
                    cuvc.isRateTailor = isRateTailor
                    cuvc.tailoringRate = tailoringRate
                    cuvc.block = callback
                    self.present(cuvc, animated: true, completion: nil)
                case .album:
                    let avc = LYAutoAlbumsController()
                    avc.maxSelects = maxSelects
                    avc.isRateTailor = isRateTailor
                    avc.tailoringRate = tailoringRate
                    avc.block = callback
                    let nav = UINavigationController(rootViewController: avc)
                    nav.navigationBar.isTranslucent = false
                    self.present(nav, animated: true, completion: nil)
                case .qrcode:
                    let qc = LYAutoQRCodeController()
                    qc.qrBlock = qr
                    let nav = UINavigationController(rootViewController: qc)
                    nav.navigationBar.tintColor = .white
                    nav.navigationBar.barStyle = .black
                    nav.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
                    nav.navigationBar.shadowImage = UIImage()
                    self.present(nav, animated: true, completion: nil)
                }
            } else {
                let errorVc = picker.getErrorController("camera")
                self.present(errorVc, animated: true, completion: nil)
            }
        }
    }
    
}

open class LYAutoPhotoPickers {
    
    public init() {}
    
    open func checkPhotoAuth(_ type: LYAutoPhotoType, _ authBlock: @escaping (Bool)->Void) {
        if type == .camera || type == .qrcode {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if authStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                        authBlock(granted)
                }
            } else if authStatus == .denied {
                authBlock(false)
            } else if authStatus == .authorized {
                authBlock(true)
            }
        } else if type == .album {
            let authStatus = PHPhotoLibrary.authorizationStatus()
            
            if authStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .denied {
                        authBlock(false)
                    } else if status == .authorized {
                        authBlock(true)
                    }
                }
            } else if authStatus == .denied {
                authBlock(false)
            } else if authStatus == .authorized {
                authBlock(true)
            }
        }
    }
    
    open func getErrorController(_ type: String) -> UIViewController {
        let aec = LYAutoAuthErrorController(nibName: "LYAutoAuthErrorController", bundle: Bundle(for: LYAutoPhotoPickers.self))
        aec.type = type
        
        let nav = UINavigationController(rootViewController: aec)
        nav.navigationBar.isTranslucent = false
        
        return nav
    }
    
}
