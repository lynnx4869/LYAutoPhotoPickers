//
//  LYAutoAuthErrorController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/27.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

class LYAutoAuthErrorController: UIViewController {
    
    var type: LYAutoPhotoType = .camera

    @IBOutlet fileprivate weak var messageLabel: UILabel!
    @IBOutlet fileprivate weak var linkLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if type == .camera || type == .qrcode {
            navigationItem.title = "相机"
            messageLabel.text = "此应用程序没有权限访问您的相机"
            linkLabel.text = "在“设置-隐私-相机”中开启即可使用"
        } else if type == .album {
            navigationItem.title = "照片"
            messageLabel.text = "此应用程序没有权限访问您的照片"
            linkLabel.text = "在“设置-隐私-照片”中开启即可查看"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goback))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func goback() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction fileprivate func settingAuth(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
