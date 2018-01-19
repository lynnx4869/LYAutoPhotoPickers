//
//  LYAutoAlert.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/5/22.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

public typealias LYAutoTitleCallback = (String) -> Void

public struct LYAutoAlert {
    
    static public func show(title: String,
                     subTitle: String,
                     check: Bool,
                     viewController: UIViewController,
                     confirm: String?,
                     cancel: String?,
                     sureAction: @escaping LYAutoTitleCallback,
                     cancelAction: @escaping LYAutoTitleCallback) {
        
        var confirmTitle = ""
        var cancelTitle = ""
        
        if check {
            if confirm == nil {
                confirmTitle = "确认"
            } else {
                confirmTitle = confirm!
            }
            
            if cancel == nil {
                cancelTitle = "取消"
            } else {
                cancelTitle = cancel!
            }
        } else {
            if confirm == nil {
                confirmTitle = "我知道了"
            } else {
                confirmTitle = confirm!
            }
        }
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        if check {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelAction("取消")
            })
            alertController.addAction(cancelAction)
            
            let sureAction = UIAlertAction(title: confirmTitle, style: .default, handler: { (action) in
                sureAction("确认")
            })
            alertController.addAction(sureAction)
        } else {
            let cancelAction = UIAlertAction(title: confirmTitle, style: .cancel, handler: { (action) in
                sureAction("确认")
            })
            alertController.addAction(cancelAction)
        }
    
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static public func show(title: String,
                     btns: [String],
                     viewController: UIViewController,
                     btnClick: @escaping LYAutoTitleCallback) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        for btn in btns {
            let btnAction = UIAlertAction(title: btn, style: .default, handler: { (action) in
                btnClick(action.title!)
            })
            alertController.addAction(btnAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}
