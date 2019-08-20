//
//  LYAutoQRScanView.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2018/1/11.
//  Copyright © 2018年 lyning. All rights reserved.
//

import UIKit

class LYAutoQRScanView: UIView {
    
    private var scanLine: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        layer.borderColor = 0x1296db.color().cgColor
        layer.borderWidth = 1.0
    }
    
    deinit {
        debugPrint("QR Scan View Reinit ...")
    }
    
    override var bounds: CGRect {
        didSet {
            super.bounds = bounds
            
            initScanLine()
            startScanAnim()
        }
    }
    
    private func initScanLine() {
        scanLine = UIView(frame: CGRect(x: 5, y: 5, width: bounds.width-10, height: 3))
        addSubview(scanLine)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = scanLine.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.colors = [0x0000ff.color().cgColor,
                                0x00bfff.color().cgColor,
                                0x0000ff.color().cgColor]
        scanLine.layer.addSublayer(gradientLayer)
        
        let w = scanLine.bounds.width
        let h = scanLine.bounds.height
        
        let path = UIBezierPath()
        let r = (w * w + h * h) / (4 * h)
        let angle = asin(w / 2 / r)
        path.addArc(withCenter: CGPoint(x: w/2, y: h-r),
                    radius: r,
                    startAngle: CGFloat.pi/2-angle,
                    endAngle: CGFloat.pi/2+angle,
                    clockwise: true)
        path.addArc(withCenter: CGPoint(x: w/2, y: r),
                    radius: r,
                    startAngle: CGFloat.pi*3/2-angle,
                    endAngle: CGFloat.pi*3/2+angle,
                    clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        scanLine.layer.mask = shapeLayer
    }
    
    private func startScanAnim() {
        UIView.animate(withDuration: 3.0,
                       animations: { [weak self] in
                        self?.scanLine.frame.origin = CGPoint(x: 5, y: (self?.bounds.height)!-8)
        }) { [weak self] (result) in
            self?.scanLine.frame.origin = CGPoint(x: 5, y: 5)
            self?.startScanAnim()
        }
    }
    
}
