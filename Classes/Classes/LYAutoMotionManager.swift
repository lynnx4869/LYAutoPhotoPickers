//
//  LYAutoMotionManager.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2018/6/4.
//  Copyright © 2018年 lyning. All rights reserved.
//

import CoreMotion
import UIKit

class LYAutoMotionManager {
        
    fileprivate let manager = CMMotionManager()
    
    func get(_ cb: @escaping (UIDeviceOrientation)->Void) {
        if manager.isDeviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 1
            manager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motion, error) in
                if let motion = motion {
                    let x = motion.gravity.x
                    let y = motion.gravity.y
                    
                    if fabs(y) >= fabs(x) {
                        if y >= 0 {
                            cb(UIDeviceOrientation.portraitUpsideDown)
                        } else {
                            cb(UIDeviceOrientation.portrait)
                        }
                    } else {
                        if x >= 0 {
                            cb(UIDeviceOrientation.landscapeRight)
                        } else {
                            cb(UIDeviceOrientation.landscapeLeft)
                        }
                    }
                    
                    self.manager.stopDeviceMotionUpdates()
                }
            }
        }
    }
    
}
