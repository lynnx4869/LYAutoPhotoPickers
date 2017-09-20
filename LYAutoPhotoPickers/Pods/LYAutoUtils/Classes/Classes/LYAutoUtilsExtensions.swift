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
    public func pureImage() -> UIImage {
        let imageSize = CGSize(width: 10, height: 10)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        set()
        UIRectFill(CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        
        let pureImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return pureImage
    }
    
}

public extension UIImage {
    
    /// 绘制图片颜色
    ///
    /// - Parameter color: UIColor
    /// - Returns: New Image
    public func imageChange(color: UIColor) -> UIImage {
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
    public func compress() -> UIImage {
        let width = size.width
        let height = size.height

        var newWidth: CGFloat = width
        var newHeight: CGFloat = height
        
        if width <= 1280 && height <= 1280 {
            newWidth = width
            newHeight = height
        } else if (width > 1280 || height > 1280) && width/height <= 2.0 {
            if width > height {
                newWidth = 1280
                newHeight = 1280 * height / width
            } else {
                newWidth = 1280 * width / height
                newHeight = 1280
            }
        } else if (width > 1280 || height > 1280) && width/height > 2.0 && (width < 1280 || height < 1280) {
            newWidth = width
            newHeight = height
        } else if width > 1280 && height > 1280 && width/height > 2.0 {
            if width > height {
                newWidth = 1280 * width / height
                newHeight = 1280
            } else {
                newWidth = 1280
                newHeight = 1280 * height / width
            }
        }
        
        let imageSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(imageSize)
        draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let newData = UIImageJPEGRepresentation(scaledImage!, 0.5)
        
        return UIImage(data: newData!)!
    }
    
    /// 将图片转成Base64码
    ///
    /// - Parameter url: 图片路径
    /// - Returns: Base64字符串
    static public func image(url: String) -> String {
        let image = UIImage(contentsOfFile: url)
        let scaledImage = image?.compress()
        
        return (UIImagePNGRepresentation(scaledImage!)?.base64EncodedString(options: .endLineWithLineFeed))!
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



