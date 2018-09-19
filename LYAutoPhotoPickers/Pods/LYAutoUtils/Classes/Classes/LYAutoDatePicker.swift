//
//  LYAutoDatePicker.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/9/1.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

public enum LYAutoDatepickerType: Int {
    case YMD
    case YMDHmS
}

open class LYAutoDatePicker: UIViewController {
    
    public static func show(type: LYAutoDatepickerType,
                          time: Date?,
                          maxTime: Date?,
                          minTime: Date?,
                          color: UIColor?,
                          sureAction: @escaping (Date)->Void) -> LYAutoDatePicker {
        
        let datepicker = LYAutoDatePicker(nibName: "LYAutoDatePicker", bundle: Bundle(for: LYAutoUtils.self))
        
        datepicker.type = type
        datepicker.time = time
        datepicker.maxTime = maxTime
        datepicker.minTime = minTime
        datepicker.color = color
        datepicker.sureAction = sureAction
        
        datepicker.view.backgroundColor = .clear
        datepicker.modalPresentationStyle = .overCurrentContext
        datepicker.modalTransitionStyle = .crossDissolve
        
        return datepicker
    }
    
    open var type: LYAutoDatepickerType!
    open var time: Date?
    open var maxTime: Date?
    open var minTime: Date?
    open var color: UIColor?
    open var sureAction: ((Date)->Void)!
    
    @IBOutlet weak fileprivate var cancelBtn: UIButton!
    @IBOutlet weak fileprivate var sureBtn: UIButton!
    @IBOutlet weak fileprivate var datepicker: UIDatePicker!
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if type == .YMD {
            datepicker.datePickerMode = .date
        } else if type == .YMDHmS {
            datepicker.datePickerMode = .dateAndTime
        }
        
        if time == nil {
            time = Date()
        }
        datepicker.date = time!
        
        if maxTime != nil {
            datepicker.maximumDate = maxTime!
        }
        
        if minTime != nil {
            datepicker.minimumDate = minTime!
        }
        
        if color == nil {
            color = 0xff9000.color()
        }
        setComponentsColor(color: color!)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setComponentsColor(color: UIColor) {
        datepicker.tintColor = color
        cancelBtn.setTitleColor(color, for: .normal)
        cancelBtn.setTitleColor(color, for: .highlighted)
        sureBtn.setTitleColor(color, for: .normal)
        sureBtn.setTitleColor(color, for: .highlighted)
    }
    
    @IBAction func dateChange(_ sender: UIDatePicker) {
        time = sender.date
    }
    
    @IBAction fileprivate func cancelAction(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction fileprivate func sureAction(_ sender: UIButton) {
        sureAction(time!)
        dismiss(animated: false, completion: nil)
    }
    

}
