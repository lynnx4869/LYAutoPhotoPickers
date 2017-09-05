//
//  LYAutoSwitchs.swift
//  LYAutoUtils
//
//  Created by xianing on 2017/5/22.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import pop

public class LYAutoSwitchs: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var titles: [String] = [] {
        didSet {
            if titles.count <= 3 {
                collectionView.isScrollEnabled = false
                selectLine.frame = CGRect(x: 20, y: bounds.size.height-3, width: bounds.size.width/CGFloat(titles.count)-40, height: 3)
            } else {
                collectionView.isScrollEnabled = true
                selectLine.frame = CGRect(x: 20, y: bounds.size.height-3, width: bounds.size.width/3-40, height: 3)
            }
            
            collectionView.reloadData()
        }
    }
    
    public var curIndex: Int = 0 {
        willSet {
            let oldCell = collectionView.cellForItem(at: IndexPath(row: curIndex, section: 0)) as? LYAutoSwitchCell
            let newCell = collectionView.cellForItem(at: IndexPath(row: newValue, section: 0)) as! LYAutoSwitchCell
            
            if oldCell != nil {
                oldCell?.isSelect = false
            }
            newCell.isSelect = true
            
            if titles.count > 3 {
                if newValue + 1 < titles.count {
                    collectionView.scrollToItem(at: IndexPath(item: newValue+1, section: 0), at: .right, animated: true)
                } else {
                    collectionView.scrollToItem(at: IndexPath(item: newValue, section: 0), at: .right, animated: true)
                }
            }
            
            let moveAnim = POPBasicAnimation(propertyNamed: kPOPViewCenter)
            moveAnim?.toValue = CGPoint(x: newCell.center.x, y: bounds.size.height-1.5)
            moveAnim?.duration = 0.5
            selectLine.pop_add(moveAnim, forKey: "moving")
        }
    }
    
    public var clickCallback: ((_ index: Int)->Void)!
    
    public init(frame: CGRect, color: UIColor?) {
        super.init(frame: frame)
        
        backgroundColor = .white
        curIndex = 0
        
        if color != nil {
            self.color = color!
        }
        
        createViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var color: UIColor = UIColor.color(hex: 0x007cdc)
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var selectLine: UIView!
    
    fileprivate func createViews() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LYAutoSwitchCell.classForCoder(), forCellWithReuseIdentifier: "LYAutoSwitchCellId")
        addSubview(collectionView)
        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: bounds.size.height-1, width: bounds.size.width, height: 1)
        bottomLine.backgroundColor = UIColor.color(hex: 0xEEEEEE).cgColor
        layer.addSublayer(bottomLine)
        
        selectLine = UIView()
        selectLine.backgroundColor = color
        collectionView.addSubview(selectLine)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if titles.count < 3 {
           return CGSize(width: bounds.size.width/CGFloat(titles.count), height: bounds.size.height)
        } else{
            return CGSize(width: bounds.size.width/3.0, height: bounds.size.height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYAutoSwitchCellId", for: indexPath) as! LYAutoSwitchCell
        
        cell.color = color
        cell.title = titles[indexPath.item]
        cell.isShowRight = indexPath.item != (titles.count-1)
        cell.isSelect = indexPath.item == curIndex
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        curIndex = indexPath.item
        clickCallback(curIndex)
    }
    
}

fileprivate class LYAutoSwitchCell: UICollectionViewCell {

    open var color: UIColor = UIColor.color(hex: 0x007cdc)
    
    open var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    open var isShowRight: Bool = true {
        didSet {
            if isShowRight {
                rightLine.isHidden = false
            } else {
                rightLine.isHidden = true
            }
        }
    }
    
    open var isSelect: Bool = false {
        didSet {
            if isSelect {
                titleLabel.textColor = color
            } else {
                titleLabel.textColor = UIColor.color(hex: 0x333333)
            }
        }
    }
    
    fileprivate var titleLabel: UILabel!
    fileprivate var rightLine: CALayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel = UILabel(frame: bounds)
        titleLabel.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.color(hex: 0x333333)
        addSubview(titleLabel)
        
        rightLine = CALayer()
        rightLine.backgroundColor = UIColor.color(hex: 0xCCCCCC).cgColor
        rightLine.frame = CGRect(x: bounds.size.width-1, y: 10, width: 1, height: bounds.size.height-20)
        layer.addSublayer(rightLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


