//
//  LYAutoPhotoBasicController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/28.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

class LYAutoPhotoBasicController: UIViewController {
    
    var isRateTailor: Bool = false
    var tailoringRate: Double = 0
    var block: LYAutoCallback = { _,_ in }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
