//
//  ViewController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/15.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import LYAutoUtils

class ViewController: UIViewController {

    @IBOutlet weak var displayImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.title = "主页"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickImage(_ sender: UIButton) {
        LYAutoAlert.show(title: "",
                         btns: ["相机", "相册", "扫描二维码"],
                         viewController: self)
        { (title) in
            var type = LYAutoPhotoType.camera
            if title == "相机" {
                type = .camera
            } else if title == "相册" {
                type = .album
            } else {
                type = .qrcode
            }
            
            self.showPickers(type: type, callback: { [weak self] photos in
                if let photos = photos {
                    let photo = photos.first
                    self?.displayImage.image = photo?.image
                    
                    let path = NSHomeDirectory() + "/Documents/\(Date().description).png"
                    let fileManager = FileManager.default
                    fileManager.createFile(atPath: path,
                                           contents: UIImagePNGRepresentation((photo?.image)!),
                                           attributes: nil)
                } else {
                    debugPrint("photo picker cancel...")
                }
            }, qr: { url in
                if let u = url {
                    debugPrint(u)
                }
            })
        }
    }

}

