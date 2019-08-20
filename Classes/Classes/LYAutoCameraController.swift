//
//  LYAutoCameraController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/28.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

class LYAutoCameraController: LYAutoPhotoBasicController {
    
    private var cameraView: LYAutoCameraView!
    private var photoView: LYAutoPhotoView!
    
    var image: UIImage? {
        didSet {
            if self.image != nil {
                photoView.displayImage.image = image
                
                cameraView.isHidden = true
                photoView.isHidden = false
            } else {
                photoView.displayImage.image = nil
                
                cameraView.isHidden = false
                photoView.isHidden = true
                
                cameraView.startSession()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let plugins = Bundle(for: LYAutoPhotoPickers.self).loadNibNamed("LYAutoPlugins", owner: nil, options: nil) {
            for plugin in plugins {
                if let cv = plugin as? LYAutoCameraView {
                    cv.cc = self
                    cv.frame = view.bounds
                    view.addSubview(cv)
                    
                    cameraView = cv
                    
                    continue
                }
                if let pv = plugin as? LYAutoPhotoView {
                    pv.cc = self
                    pv.frame = view.bounds
                    view.addSubview(pv)
                    
                    photoView = pv
                    photoView.isHidden = true
                    
                    continue
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("LY Auto Camera alloc ...")
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}
