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
import CropViewController
import JXPhotoBrowser

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
        countLabel.textColor = 0xc3c3c3.color()
        countLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(countLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LYAutoPhotosController: LYAutoPhotoBasicController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PhotoBrowserDelegate, CropViewControllerDelegate, LYAutoPhotoTapDelegate {

    var assetCollection: PHAssetCollection!
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    @IBOutlet fileprivate weak var cutBtn: UIButton!
    @IBOutlet fileprivate weak var sureBtn: UIButton!
    
    fileprivate var photos = [LYAutoPhoto]()
    fileprivate var selectPhotos = [LYAutoPhoto]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        navigationItem.title = assetCollection.localizedTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(goBack))
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "LYAutoPhotoSelectCell", bundle: Bundle(for: LYAutoPhotoPickers.self)), forCellWithReuseIdentifier: "LYAutoPhotoSelectCellId")
        collectionView.register(LYAutoPhotoHeaderView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "LYAutoPhotoHeaderViewId")
        collectionView.register(LYAutoPhotoFooterView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LYAutoPhotoFooterViewId")
        
        collectionView.isHidden = true
        
        cutBtn.isEnabled = false
        sureBtn.isEnabled = false
        
        DispatchQueue.global().async {
            [weak self] in
            
            if let assetCollection = self?.assetCollection {
                let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                for i in 0..<assets.count {
                    let photo = LYAutoPhoto()
                    photo.asset = assets[i]
                    self?.photos.append(photo)
                }
            }
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                
                if let ch = self?.collectionView.contentSize.height,
                    let bh = self?.collectionView.bounds.size.height {
                    var yOffset: CGFloat = 0
                    if ch > bh {
                        yOffset = ch - bh
                    }
                    
                    self?.collectionView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: false)
                    self?.collectionView.isHidden = false
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("photos view controller dealloc")
    }
    
    @objc fileprivate func goBack() {
        block(nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cutPhoto(_ sender: Any) {
        guard let photo = selectPhotos.first else {
            return
        }
        
        let cvc = CropViewController(image: photo.image)
        cvc.delegate = self
        cvc.rotateClockwiseButtonHidden = false
        if isRateTailor {
            cvc.customAspectRatio = CGSize(width: tailoringRate, height: 1.0)
            cvc.aspectRatioLockEnabled = true
            cvc.resetAspectRatioEnabled = false
            cvc.aspectRatioLockEnabled = true
        }
        
        navigationController?.pushViewController(cvc, animated: false)
    }
    
    @IBAction func sureSelectPhotos(_ sender: Any) {
        block(selectPhotos)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func tapPhoto(sender: UIView?, index: Int) {
        let photo = photos[index]
        
        if selectPhotos.contains(photo) {
            if let i = selectPhotos.index(of: photo) {
                selectPhotos.remove(at: i)
            }
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
            
            if #available(iOS 9.0, *) {
                if photo.asset.sourceType == .typeCloudShared {
                    LYAutoAlert.show(title: "提示",
                                     subTitle: "该图片储存于云端，请先前往相册同步到本地",
                        check: false,
                        viewController: self,
                        confirm: nil,
                        cancel: nil,
                        sureAction: { (title) in
                            
                    }, cancelAction: { (title) in
                        
                    })
                    
                    return
                }
            }
            
            if photo.image == nil {
                photo.image = photo.asset.getOriginAssetImage()
            }
            selectPhotos.append(photo)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (LyConsts.ScreenWidth - 15) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LYAutoPhotoSelectCellId", for: indexPath) as! LYAutoPhotoSelectCell
        
        cell.delegate = self
        cell.currentIndex = indexPath.item
        
        let photo = photos[indexPath.item]
        
        if photo.tumImage == nil {
            photo.tumImage = photo.asset.getTumAssetImage()
        }
        
        cell.tumImage.image = photo.tumImage
        
        if selectPhotos.contains(photo) {
            if let i = selectPhotos.index(of: photo) {
                cell.selectTag.text = String(i+1)
            }
            cell.selectTag.backgroundColor = 0x1296db.color()
        } else {
            cell.selectTag.text = ""
            cell.selectTag.backgroundColor = 0xffffff.color(0.3)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        
        if #available(iOS 9.0, *) {
            if photo.asset.sourceType == .typeCloudShared {
                LYAutoAlert.show(title: "提示",
                                 subTitle: "该图片储存于云端，请先前往相册同步到本地",
                                 check: false,
                                 viewController: self,
                                 confirm: nil,
                                 cancel: nil,
                                 sureAction: { (title) in
                                    
                }, cancelAction: { (title) in
                    
                })
                
                return
            }
        }
        
        let browser = PhotoBrowser()
        browser.animationType = .scale
        browser.photoBrowserDelegate = self
        browser.plugins.append(NumberPageControlPlugin())
        browser.originPageIndex = indexPath.item
        browser.show()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: LyConsts.ScreenWidth, height: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: LyConsts.ScreenWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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
    
    //MARK: - PhotoBrowserDelegate
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return photos.count
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return collectionView.cellForItem(at: IndexPath(item: index, section: 0))
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        let photo = photos[index]
        if photo.tumImage == nil {
            photo.tumImage = photo.asset.getTumAssetImage()
        }
        return photo.tumImage
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, localImageForIndex index: Int) -> UIImage? {
        let photo = photos[index]
        if photo.image == nil {
            photo.image = photo.asset.getOriginAssetImage()
        }
        return photo.image
    }
    
    //MARK: - CropViewControllerDelegate
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.navigationController?.popViewController(animated: false)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        if let photo = selectPhotos.first {
            photo.image = image
            block([photo])
        }
        
        cropViewController.navigationController?.popViewController(animated: false)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
