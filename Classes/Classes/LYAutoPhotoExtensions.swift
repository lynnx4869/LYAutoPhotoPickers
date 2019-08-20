//
//  LYAutoPhotoExtensions.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/7/3.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos

let kPhotoTumLength: Int = 200

extension PHAsset {
    
    func getAssetImage(_ size: CGSize) -> UIImage? {
        return autoreleasepool { () -> UIImage? in
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            let semaphore = DispatchSemaphore(value: 0)
            
            
            var image: UIImage?
            PHImageManager.default().requestImage(for: self,
                                                  targetSize: size,
                                                  contentMode: .default,
                                                  options: options)
            { (result, info) in
                image = result
                semaphore.signal()
            }
            
            semaphore.wait()
            return image
        }
    }
    
    func getOriginAssetImage() -> UIImage? {
        return getAssetImage(PHImageManagerMaximumSize)
    }
    
    func getTumAssetImage() -> UIImage? {
        var size = CGSize.zero
        if self.pixelWidth > kPhotoTumLength {
            size = CGSize(width: kPhotoTumLength, height: kPhotoTumLength*self.pixelHeight/self.pixelWidth)
        } else if self.pixelHeight > kPhotoTumLength {
            size = CGSize(width: kPhotoTumLength*self.pixelWidth/self.pixelHeight, height: kPhotoTumLength)
        } else {
            size = CGSize(width: self.pixelWidth, height: self.pixelHeight)
        }
        
        return getAssetImage(size)
    }
    
}


extension UIImage {
    
    func fix(_ orientation: UIDeviceOrientation, _ position: AVCaptureDevice.Position) -> UIImage? {
        if let ci = cgImage {
            if position == .front {
                switch orientation {
                case .portrait, .faceUp, .faceDown, .unknown:
                    return self
                case .portraitUpsideDown:
                    return UIImage(cgImage: ci, scale: scale, orientation: .left)
                case .landscapeLeft:
                    return UIImage(cgImage: ci, scale: scale, orientation: .down)
                case.landscapeRight:
                    return UIImage(cgImage: ci, scale: scale, orientation: .up)
                @unknown default:
                    return self
                }
            } else {
                switch orientation {
                case .portrait, .faceUp, .faceDown, .unknown:
                    return self
                case .portraitUpsideDown:
                    return UIImage(cgImage: ci, scale: scale, orientation: .left)
                case .landscapeLeft:
                    return UIImage(cgImage: ci, scale: scale, orientation: .up)
                case.landscapeRight:
                    return UIImage(cgImage: ci, scale: scale, orientation: .down)
                @unknown default:
                    return self
                }
            }
        }
        
        return nil
    }
    
}
