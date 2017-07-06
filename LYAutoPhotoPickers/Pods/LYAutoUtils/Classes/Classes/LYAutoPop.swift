//
//  LYAutoPop.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/5/22.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import pop

public enum LYAutoPopType: Int {
    case success
    case warming
    case error
}

public struct LYAutoPop {
    
    static public func show(message: String, type: LYAutoPopType, duration: TimeInterval) {
        let autoPopView = LYAutoPopView(frame: CGRect(x: 0, y: 64, width: LyConsts.ScreenWidth, height: 30), message: message, type: type)
        UIApplication.shared.keyWindow?.addSubview(autoPopView)
        
        let addAnim = POPBasicAnimation(propertyNamed: kPOPViewAlpha)
        addAnim?.fromValue = 0.0
        addAnim?.toValue = 1.0
        addAnim?.duration = 1.0
        autoPopView.pop_add(addAnim, forKey: "fade")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+duration) { 
            [unowned autoPopView] in
            autoPopView.pop_removeAnimation(forKey: "fade")
            autoPopView.removeFromSuperview()
        }
    }
    
}

fileprivate class LYAutoPopView: UIView {
    
    fileprivate let leftIcon = UIImageView(frame: CGRect(x: 10, y: 8, width: 14, height: 14))
    fileprivate let messageLabel = UILabel(frame: CGRect(x: 34, y: 0, width: LyConsts.ScreenWidth-44, height: 30))
    
    init(frame: CGRect, message: String, type: LYAutoPopType) {
        super.init(frame: frame)
        
        addSubview(leftIcon)
        
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        messageLabel.textColor = .white
        addSubview(messageLabel)
        
        setType(message: message, type: type)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setType(message: String, type: LYAutoPopType) {
        messageLabel.text = message
        
        if type == .success {
            backgroundColor = UIColor.color(hex: 0x16A085)
            leftIcon.image = UIImage(named: "ly_message_ok")
        } else {
            backgroundColor = UIColor.color(hex: 0xD9544F)
            leftIcon.image = UIImage(named: "ly_message_warning")
        }
    }
    
}
