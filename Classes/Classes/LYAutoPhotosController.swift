//
//  LYAutoPhotosController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/30.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos
import LYAutoUtils
import TOCropViewController
import SKPhotoBrowser

class LYAutoPhotoAsset: NSObject {
    
    var asset: PHAsset!
    var tumImage: UIImage!
    
}

class LYAutoPhotoHeaderView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LYAutoPhotoFooterView: UICollectionReusableView {
    
    var countLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        countLabel = UILabel(frame: bounds)
        countLabel.textAlignment = .center
        countLabel.textColor = UIColor.color(hex: 0xc3c3c3)
        countLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LYAutoPhotosController: LYAutoPhotoBasicController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TOCropViewControllerDelegate, LYAutoPhotoTapDelegate {

    public var maxSelects: Int!
    public var assetCollection: PHAssetCollection!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var cutBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton!
    
    fileprivate var photos = [LYAutoPhotoAsset]()
    fileprivate var selectPhotos = [LYAutoPhotoAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        navigationItem.title = assetCollection.localizedTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goBack))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "LYAutoPhotoSelectCell", bundle: Bundle.main), forCellWithReuseIdentifier: "LYAutoPhotoSelectCellId")
        collectionView.register(LYAutoPhotoHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "LYAutoPhotoHeaderViewId")
        collectionView.register(LYAutoPhotoFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LYAutoPhotoFooterViewId")
        
        collectionView.isHidden = true
        
        cutBtn.isEnabled = false
        sureBtn.isEnabled = false
        
        DispatchQueue.global().async {
            [weak self] in
            
            let assets = PHAsset.fetchAssets(in: (self?.assetCollection)!, options: nil)
            assets.enumerateObjects({ (asset, idx, info) in
                let photoAsset = LYAutoPhotoAsset()
                photoAsset.asset = asset
                self?.photos.append(photoAsset)
            })
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
            
            DispatchQueue.main.async {
                var yOffset: CGFloat = 0
                if (self?.collectionView.contentSize.height)! > (self?.collectionView.bounds.size.height)! {
                    yOffset = (self?.collectionView.contentSize.height)! - (self?.collectionView.bounds.size.height)!
                }
                
                self?.collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
                
                self?.collectionView.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("photos view controller dealloc")
    }
    
    @objc fileprivate func goBack() {
        self.block!(false, nil)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cutPhoto(_ sender: Any) {
        let asset = selectPhotos.first?.asset
        
        let tcvc = TOCropViewController(image: (asset?.getOriginAssetImage())!)
        tcvc.delegate = self
        tcvc.rotateClockwiseButtonHidden = false
        if isRateTailor {
            tcvc.customAspectRatio = CGSize(width: tailoringRate, height: 1.0)
            tcvc.aspectRatioLockEnabled = true
            tcvc.resetAspectRatioEnabled = false
            tcvc.aspectRatioPickerButtonHidden = true
        }
        present(UINavigationController(rootViewController: tcvc), animated: true, completion: nil)
    }
    
    @IBAction func sureSelectPhotos(_ sender: Any) {
        var images = [UIImage]()
        for photoAsset in selectPhotos {
            images.append(photoAsset.asset.getOriginAssetImage())
        }
        self.block!(true, images)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    internal func tapPhoto(sender: UIView?, index: Int) {
        let photoAsset = photos[index]
        
        if selectPhotos.contains(photoAsset) {
            selectPhotos.remove(at: selectPhotos.index(of: photoAsset)!)
        } else {
            if selectPhotos.count == maxSelects && maxSelects != 0 {
                LYAutoAlert.show(title: "提示",
                                 subTitle: "最多只能选择\(String(maxSelects))张照片",
                                 check: false,
                                 viewController: self,
                                 confirm: nil,
                                 cancel: nil,
                                 sureAction: { (title) in
                                    
                }, cancelAction: { (title) in
                    
                })
                
                return
            }
            
            selectPhotos.append(photoAsset)
        }
        
        if selectPhotos.count == 1 {
            cutBtn.isEnabled = true
        } else {
            cutBtn.isEnabled = false
        }
        
        if selectPhotos.count > 0 {
            sureBtn.isEnabled = true
        } else {
            sureBtn.isEnabled = false
        }
        
        collectionView.reloadData()
    }
    
    //MARK: - UICollectionViewDelegate
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (LyConsts.ScreenWidth - 15) / 4
        return CGSize(width: width, height: width)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYAutoPhotoSelectCellId", for: indexPath) as! LYAutoPhotoSelectCell
        
        cell.delegate = self
        cell.currentIndex = indexPath.item
        
        let photoAsset = photos[indexPath.item]
        
        if photoAsset.tumImage == nil {
            photoAsset.tumImage = photoAsset.asset.getTumAssetImage()
        }
        
        cell.tumImage.image = photoAsset.tumImage
        
        if selectPhotos.contains(photoAsset) {
            cell.selectTag.text = String(describing: selectPhotos.index(of: photoAsset)!+1)
            cell.selectTag.backgroundColor = UIColor.color(hex: 0x1296DB)
        } else {
            cell.selectTag.text = ""
            cell.selectTag.backgroundColor = UIColor.color(hex: 0xffffff, alpha: 0.3)
        }
        
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! LYAutoPhotoSelectCell
        let originImage = cell.tumImage.image
        
        let photoAsset = photos[indexPath.item]
        let array: [SKPhoto] = [SKPhoto.photoWithImage(photoAsset.asset.getOriginAssetImage())]
        
        SKPhotoBrowserOptions.displayToolbar = false
        SKPhotoBrowserOptions.displayCounterLabel = false
        SKPhotoBrowserOptions.displayBackAndForwardButton = false
        SKPhotoBrowserOptions.displayAction = false
        SKPhotoBrowserOptions.displayHorizontalScrollIndicator = false
        SKPhotoBrowserOptions.displayVerticalScrollIndicator = false
        SKPhotoBrowserOptions.displayStatusbar = false
        SKPhotoBrowserOptions.displayDeleteButton = false
        SKPhotoBrowserOptions.enableZoomBlackArea = true
        SKPhotoBrowserOptions.enableSingleTapDismiss = true
        SKPhotoBrowserOptions.bounceAnimation = true
        
        let browser = SKPhotoBrowser(originImage: originImage!, photos: array, animatedFromView: cell)
        present(browser, animated: true, completion: nil)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: LyConsts.ScreenWidth, height: 5)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: LyConsts.ScreenWidth, height: 30)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var supplementaryView: UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "LYAutoPhotoHeaderViewId", for: indexPath) as! LYAutoPhotoHeaderView
            supplementaryView = headerView
        }
        
        if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LYAutoPhotoFooterViewId", for: indexPath) as! LYAutoPhotoFooterView
            footerView.countLabel.text = "共\(photos.count)张照片"
            supplementaryView = footerView
        }
        
        return supplementaryView
    }
    
    //MARK: - TOCropViewControllerDelegate
    internal func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    internal func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, rect cropRect: CGRect, angle: Int) {
        self.block!(true, [image])
        
        cropViewController.dismiss(animated: false) { 
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
}
