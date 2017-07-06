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

public extension PHAsset {
    
    public func getAssetImage(size: CGSize) -> UIImage {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        
        var image: UIImage!
        PHImageManager.default().requestImage(for: self,
                                              targetSize: size,
                                              contentMode: .default,
                                              options: options)
        { (result, info) in
            image = result
        }
        
        return image
    }
    
    public func getOriginAssetImage() -> UIImage {
        return getAssetImage(size: CGSize(width: self.pixelWidth, height: self.pixelHeight))
    }
    
    public func getTumAssetImage() -> UIImage {
        var size = CGSize.zero
        if self.pixelWidth > kPhotoTumLength {
            size = CGSize(width: kPhotoTumLength, height: kPhotoTumLength*self.pixelHeight/self.pixelWidth)
        } else if self.pixelHeight > kPhotoTumLength {
            size = CGSize(width: kPhotoTumLength*self.pixelWidth/self.pixelHeight, height: kPhotoTumLength)
        } else {
            size = CGSize(width: self.pixelWidth, height: self.pixelHeight)
        }
        
        return getAssetImage(size: size)
    }
    
}


