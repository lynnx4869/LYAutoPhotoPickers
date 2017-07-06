//
//  LYAutoAuthErrorController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/27.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

class LYAutoAuthErrorController: UIViewController {
    
    public var type: LYAutoPhotoType = .camera

    @IBOutlet fileprivate weak var messageLabel: UILabel!
    @IBOutlet fileprivate weak var linkLabel: UILabel!
    
    @IBOutlet fileprivate weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if navigationController != nil {
            navigationController?.navigationBar.isHidden = true
        }
        
        if type == .camera || type == .qrcode {
            navigationBar.topItem?.title = "相机"
            messageLabel.text = "此应用程序没有权限访问您的相机"
            linkLabel.text = "在“设置-隐私-相机”中开启即可使用"
        } else if type == .album {
            navigationBar.topItem?.title = "照片"
            messageLabel.text = "此应用程序没有权限访问您的照片"
            linkLabel.text = "在“设置-隐私-照片”中开启即可查看"
        }
        
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goback))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc fileprivate func goback() {
        if navigationController == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction fileprivate func settingAuth(_ sender: UIButton) {
        if Double(UIDevice.current.systemVersion)! >= 10.0 {
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        } else {
            var url: URL!
            switch type {
            case .camera:
                url = URL(string: "Prefs:root=Privacy&path=CAMERA")
                break
            case .album:
                url = URL(string: "Prefs:root=Privacy&path=PHOTOS")
                break
            case .qrcode:
                url = URL(string: "Prefs:root=Privacy&path=CAMERA")
                break
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
