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

    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var linkLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        switch type {
        case .camera, .qrcode:
            navigationItem.title = "相机"
            messageLabel.text = "此应用程序没有权限访问您的相机"
            linkLabel.text = "在“设置-隐私-相机”中开启即可使用"
        case .album:
            navigationItem.title = "照片"
            messageLabel.text = "此应用程序没有权限访问您的照片"
            linkLabel.text = "在“设置-隐私-照片”中开启即可查看"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goback(_:)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func goback(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func settingAuth(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
