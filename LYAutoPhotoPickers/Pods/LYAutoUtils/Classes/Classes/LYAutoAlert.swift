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
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        if check {
            var confirmTitle = ""
            if let confirmStr = confirm {
                confirmTitle = confirmStr
            } else {
                confirmTitle = "确认"
            }
            
            var cancelTitle = ""
            if let cancelStr = cancel {
                cancelTitle = cancelStr
            } else {
                cancelTitle = "取消"
            }
            
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
                cancelAction("取消")
            })
            alertController.addAction(cancelAction)
            
            let sureAction = UIAlertAction(title: confirmTitle, style: .default, handler: { (action) in
                sureAction("确认")
            })
            alertController.addAction(sureAction)
        } else {
            var confirmTitle: String
            if let confirmStr = confirm {
                confirmTitle = confirmStr
            } else {
                confirmTitle = "我知道了"
            }
            
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
