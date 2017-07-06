//
//  LYAutoPhotoSelectCell.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/30.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit

public protocol LYAutoPhotoTapDelegate: class {
    
    func tapPhoto(sender: UIView?, index: Int)
    
}

class LYAutoPhotoSelectCell: UICollectionViewCell {
    
    @IBOutlet weak var tumImage: UIImageView!
    @IBOutlet weak var selectTag: UILabel!
    @IBOutlet weak var selectTagBg: UIView!
    
    public var currentIndex: Int!
    public var delegate: LYAutoPhotoTapDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectTag.layer.masksToBounds = true
        selectTag.layer.cornerRadius = 10.0
        selectTag.layer.borderWidth = 1.0
        selectTag.layer.borderColor = UIColor.white.cgColor
        
        selectTagBg.isUserInteractionEnabled = true
        
        selectTagBg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhotoTag(tap:))))

    }
    
    @objc fileprivate func selectPhotoTag(tap: UITapGestureRecognizer) {
        delegate?.tapPhoto(sender: tap.view, index: currentIndex)
    }

}
