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
    
    func getAssetImage(size: CGSize) -> UIImage {
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
    
    func getOriginAssetImage() -> UIImage {
        return getAssetImage(size: CGSize(width: self.pixelWidth, height: self.pixelHeight))
    }
    
    func getTumAssetImage() -> UIImage {
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
    
    func getAssetUrl() -> URL {
        var urlString: String!
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: self,
                                                  options: options)
        { (imageData, dataUTI, orientation, info) in
            let oldUrl = info?["PHImageFileURLKey"] as! NSURL
            urlString = oldUrl.absoluteString
        }
        let url = URL(string: urlString)
        return url!
    }
    
}

extension UIView {
    
    func top(to view: UIView,
                    attribute: NSLayoutAttribute,
                    constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func bottom(to view: UIView,
                       attribute: NSLayoutAttribute,
                       constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func left(to view: UIView,
                     attribute: NSLayoutAttribute,
                     constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func right(to view: UIView,
                      attribute: NSLayoutAttribute,
                      constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func centerX(to view: UIView,
                        attribute: NSLayoutAttribute) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerX,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: 0.0)
        view.addConstraint(constraint)
    }
    
    func centerY(to view: UIView,
                        attribute: NSLayoutAttribute) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .centerY,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: attribute,
                                            multiplier: 1.0,
                                            constant: 0.0)
        view.addConstraint(constraint)
    }
    
    func width(to view: UIView,
                      constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 0.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func height(to view: UIView,
                       constant: CGFloat) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 0.0,
                                            constant: constant)
        view.addConstraint(constraint)
    }
    
    func edge(to view: UIView, padding: UIEdgeInsets) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        
        let constraintTop = NSLayoutConstraint(item: self,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: view,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: padding.top)
        let constraintBottom = NSLayoutConstraint(item: self,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: padding.bottom)
        let constraintLeft = NSLayoutConstraint(item: self,
                                                attribute: .left,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: .left,
                                                multiplier: 1.0,
                                                constant: padding.left)
        let constraintRight = NSLayoutConstraint(item: self,
                                                 attribute: .right,
                                                 relatedBy: .equal,
                                                 toItem: view,
                                                 attribute: .right,
                                                 multiplier: 1.0,
                                                 constant: padding.right)
        
        view.addConstraints([constraintTop, constraintBottom, constraintLeft, constraintRight])
    }
    
}
