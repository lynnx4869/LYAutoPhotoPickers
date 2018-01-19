//
//  LYAutoUtilsExtensions.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/5/22.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import WebKit
import SSZipArchive

/// 静态量
public struct LyConsts {
    
    static public var ScreenWidth: CGFloat! {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    static public var ScreenHeight: CGFloat! {
        get {
            return UIScreen.main.bounds.size.height
        }
    }
    
}

public extension UIColor {
    
    /// 从16进制获取UIColor
    ///
    /// - Parameters:
    ///   - hex: 16进制颜色值 ： 如 :#007ac0 即为 0x15A230
    ///   - alpha: 透明度 0 ~ 1
    /// - Returns: UIColor
    static public func color(hex: Int, alpha: CGFloat) -> UIColor {
        let color = UIColor(red: CGFloat(Double(((hex & 0xFF0000) >> 16))/255.0),
                            green: CGFloat(Double(((hex & 0xFF00) >> 8))/255.0),
                            blue: CGFloat(Double((hex & 0xFF))/255.0),
                            alpha: alpha)
        
        return color
    }
    
    /// 从16进制获取UIColor alpha 默认为1
    ///
    /// - Parameter hex: 16进制颜色值 ： 如 :#007ac0 即为 0x15A230
    /// - Returns: UIColor
    static public func color(hex: Int) -> UIColor {
        return UIColor.color(hex: hex, alpha: 1.0)
    }
    
    /// 获取纯色图片
    ///
    /// - Returns: 纯色图片
    public func pureImage() -> UIImage? {
        let imageSize = CGSize(width: 10, height: 10)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        set()
        UIRectFill(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        var pureImage: UIImage?
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            pureImage = image
        }
        UIGraphicsEndImageContext()
        
        return pureImage
    }
    
}

public extension UIImage {
    
    /// 绘制图片颜色
    ///
    /// - Parameter color: UIColor
    /// - Returns: New Image
    public func imageChange(color: UIColor) -> UIImage? {
        let imageReact = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(imageReact.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.translateBy(x: 0.0, y: -imageReact.size.height)
        context?.clip(to: imageReact, mask: cgImage!)
        context?.setFillColor(color.cgColor)
        context?.fill(imageReact)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 压缩图片
    ///
    /// - Returns: 输出图片
    public func compress() -> Data? {
        let fixelW = self.size.width
        let fixelH = self.size.height
        var thumbW = fixelW.truncatingRemainder(dividingBy: 2) == 1 ? fixelW + 1 : fixelW
        var thumbH = fixelH.truncatingRemainder(dividingBy: 2) == 1 ? fixelH + 1 : fixelH
        
        let scale = fixelW / fixelH
        var size: CGFloat = 0
        
        if scale <= 1 && scale > 0.5625 {
            if fixelH < 1664 {
                size = (fixelW * fixelH) / pow(1664, 2) * 150
                size = size < 60 ? 60 : size
            } else if fixelH >= 1664 && fixelH < 4990 {
                thumbW = fixelW / 2
                thumbH = fixelH / 2
                size   = (thumbH * thumbW) / pow(2495, 2) * 300
                size = size < 60 ? 60 : size
            } else if fixelH >= 4990 && fixelH < 10240 {
                thumbW = fixelW / 4
                thumbH = fixelH / 4
                size = (thumbW * thumbH) / pow(2560, 2) * 300
                size = size < 100 ? 100 : size
            } else {
                let multiple = fixelH / 1280 == 0 ? 1 : fixelH / 1280
                thumbW = fixelW / multiple
                thumbH = fixelH / multiple
                size = (thumbW * thumbH) / pow(2560, 2) * 300
                size = size < 100 ? 100 : size
            }
        } else if scale <= 0.5625 && scale > 0.5 {
            let multiple = fixelH / 1280 == 0 ? 1 : fixelH / 1280
            thumbW = fixelW / multiple
            thumbH = fixelH / multiple
            size = (thumbW * thumbH) / (1440.0 * 2560.0) * 400
            size = size < 100 ? 100 : size
        } else {
            let multiple = CGFloat(ceil(fixelH / (1280.0 / scale)))
            thumbW = fixelW / multiple
            thumbH = fixelH / multiple
            size = ((thumbW * thumbH) / (1280.0 * (1280 / scale))) * 500
            size = size < 100 ? 100 : size
        }
        
        if var thumbImage = fixOrientation() {
            UIGraphicsBeginImageContext(CGSize(width: thumbW, height: thumbH))
            thumbImage.draw(in: CGRect(x: 0, y: 0, width: thumbW, height: thumbH))
            if let gi = UIGraphicsGetImageFromCurrentImageContext() {
                thumbImage = gi
            }
            UIGraphicsEndImageContext()

            if let imageData = UIImageJPEGRepresentation(thumbImage, 1.0) {
                if CGFloat(imageData.count)/1024 < size {
                    return imageData
                }
            }
            
            var dataLen: Data!
            var max: CGFloat = 1.0
            var min: CGFloat = 0.0
            for _ in 0..<6 {
                let compressionQuality = (max + min) / 2
                if let imageData = UIImageJPEGRepresentation(thumbImage, compressionQuality) {
                    dataLen = imageData
                    if CGFloat(imageData.count)/1024 < size * 0.9 {
                        min = compressionQuality
                    } else if CGFloat(imageData.count)/1024 > size {
                        max = compressionQuality
                    } else {
                        break
                    }
                }
            }
            
            return dataLen
        }
        
        return nil
    }
    
    fileprivate func fixOrientation() -> UIImage? {
        if imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        if imageOrientation == .down || imageOrientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        } else if imageOrientation == .left || imageOrientation == .leftMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
        } else if imageOrientation == .right || imageOrientation == .rightMirrored {
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored {
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        } else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if let ci = cgImage {
            if let ctx = CGContext(data: nil,
                                   width: Int(size.width),
                                   height: Int(size.height),
                                   bitsPerComponent: ci.bitsPerComponent,
                                   bytesPerRow: 0,
                                   space: ci.colorSpace!,
                                   bitmapInfo: ci.bitmapInfo.rawValue) {
                ctx.concatenate(transform)

                if imageOrientation == .left ||
                    imageOrientation == .leftMirrored ||
                    imageOrientation == .right ||
                    imageOrientation == .rightMirrored {
                    ctx.draw(ci, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                } else {
                    ctx.draw(ci, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                }
                
                if let cgimg = ctx.makeImage() {
                    return UIImage(cgImage: cgimg)
                }
            }
        }
        
        return nil
    }
    
    /// 将图片转成Base64码
    ///
    /// - Parameter url: 图片路径
    /// - Returns: Base64字符串
    static public func image(url: String) -> String? {
        if let image = UIImage(contentsOfFile: url) {
            if let scaledImage = image.compress() {
                return scaledImage.base64EncodedString(options: .endLineWithLineFeed)
            }
        }
        
        return nil
    }
    
}

public extension String {
    
    /// 解压文件
    ///
    /// - Parameters:
    ///   - path: 解压到路径
    ///   - progress: 进行中
    ///   - finished: 已完成
    public func unzip(toPath path: String,
                      progress: ((String, unz_file_info, Int, Int)->Void)?,
                      finished: ((String, Bool, Error?)->Void)?) {
        SSZipArchive.unzipFile(atPath: self,
                               toDestination: path,
                               progressHandler: { (entry, zipInfo, entryNumber, total) in
                                if progress != nil {
                                    progress!(entry, zipInfo, entryNumber, total)
                                }
        })
        { (path, succeeded, error) in
            if finished != nil {
                finished!(path, succeeded, error)
            }
        }
    }
    
    /// 解压到本地
    ///
    /// - Parameters:
    ///   - progress: 进行中
    ///   - finished: 已完成
    public func unzipLocal(progress: ((String, unz_file_info, Int, Int)->Void)?,
                           finished: ((String, Bool, Error?)->Void)?) {
        var names = self.components(separatedBy: "/")
        names.removeLast()
        var rootPath = ""
        names.forEach { (name) in
            if name != "" {
                rootPath += "/\(name)"
            }
        }
        self.unzip(toPath: "\(rootPath)/", progress: progress, finished: finished)
    }
    
    /// 解压到本地并移除压缩文件
    ///
    /// - Parameters:
    ///   - progress: 进行中
    ///   - finished: 已完成
    public func unzipDelLocal(progress: ((String, unz_file_info, Int, Int)->Void)?,
                              finished: ((String, Bool, Error?)->Void)?) {
        self.unzipLocal(progress: progress, finished: finished)
        self.remove()
    }
    
    /// 移除文件
    public func remove() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self) {
            do {
                try fileManager.removeItem(atPath: self)
            } catch {
                print(error)
            }
        }
    }
    
    /// 拷贝文件
    ///
    /// - Parameter path: 拷贝文件到路径
    public func copy(toPath path: String) {
        let fileManager = FileManager.default
        do {
            let names = self.components(separatedBy: "/")
            try fileManager.copyItem(atPath: self, toPath: "\(path)/\(names[names.count-1])")
        } catch {
            print(error)
        }
    }
    
    /// 文件是否存在
    ///
    /// - Returns: 是否
    public func exists() -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: self)
    }
    
}

public extension WKWebView {
    
    /// 清空WebView
    public func cleanForDealloc() {
        loadHTMLString("", baseURL: nil)
        stopLoading()
        navigationDelegate = nil
        removeFromSuperview()
    }
}



