//
//  LYAutoAlert.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/5/22.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

public struct LYAutoAlert {
    
    static public func show(title: String,
                     subTitle: String,
                     check: Bool,
                     viewController: UIViewController,
                     sure: @escaping ((_ title: String)->Void),
                     cancel: @escaping ((_ title: String)->Void)) {
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        if check {
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                cancel("取消")
            })
            alertController.addAction(cancelAction)
            
            let sureAction = UIAlertAction(title: "确认", style: .default, handler: { (action) in
                sure("确认")
            })
            alertController.addAction(sureAction)
        } else {
            let cancelAction = UIAlertAction(title: "我知道了", style: .cancel, handler: { (action) in
                sure("确认")
            })
            alertController.addAction(cancelAction)
        }
    
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static public func show(title: String,
                     btns: [String],
                     viewController: UIViewController,
                     btnClick: @escaping ((_ title: String)->Void)) {
        
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
