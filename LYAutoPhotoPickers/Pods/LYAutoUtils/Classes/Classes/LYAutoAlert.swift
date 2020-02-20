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
    
    static public func show(title: String? = nil,
                     subTitle: String? = nil,
                     check: Bool = false,
                     viewController: UIViewController,
                     confirm: String = "确认",
                     cancel: String = "取消",
                     sureAction: @escaping LYAutoTitleCallback = { _ in },
                     cancelAction: @escaping LYAutoTitleCallback = { _ in }) {
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        if check {
            let cancelAction = UIAlertAction(title: cancel, style: .cancel, handler: { (action) in
                cancelAction("取消")
            })
            alertController.addAction(cancelAction)
            
            let sureAction = UIAlertAction(title: confirm, style: .default, handler: { (action) in
                sureAction("确认")
            })
            alertController.addAction(sureAction)
        } else {
            let cancelAction = UIAlertAction(title: confirm, style: .cancel, handler: { (action) in
                sureAction("确认")
            })
            alertController.addAction(cancelAction)
        }
    
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static public func show(title: String? = nil,
                     btns: [String] = [],
                     viewController: UIViewController,
                     btnClick: @escaping LYAutoTitleCallback = { _ in }) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            btnClick("取消")
        })
        alertController.addAction(cancelAction)
        
        for btn in btns {
            let btnAction = UIAlertAction(title: btn, style: .default, handler: { (action) in
                if let title = action.title {
                    btnClick(title)
                } else {
                    btnClick("")
                }
            })
            alertController.addAction(btnAction)
        }
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}
