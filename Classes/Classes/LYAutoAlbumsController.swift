//
//  LYAutoAlbumsController.swift
//  LYAutoPhotoPickers
//
//  Created by xianing on 2017/6/30.
//  Copyright © 2017年 lyning. All rights reserved.
//

import UIKit
import Photos

class LYAutoAlbumModel {
    var assetCollection: PHAssetCollection!
    
    var title: String!
    var count: Int!
    var image: UIImage!
}

class LYAutoAlbumsController: LYAutoPhotoBasicController, UITableViewDelegate, UITableViewDataSource {
        
    fileprivate var array = [LYAutoAlbumModel]()
    fileprivate var tableView: UITableView!
    
    fileprivate var userLibrary: PHAssetCollection!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        navigationItem.title = "照片"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(goBack(_:)))
        
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "LYAutoAlbumCell",
                                 bundle: Bundle(for: LYAutoPhotoPickers.self)),
                           forCellReuseIdentifier: "LYAutoAlbumCellId")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        
        DispatchQueue.global().async {
            [weak self] in
            
            let sysAssetCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
            
            sysAssetCollections.enumerateObjects({ (assetCollection, idx, info) in
                let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                
                if assets.count != 0 {
                    let albumModel = LYAutoAlbumModel()
                    albumModel.assetCollection = assetCollection
                    self?.array.append(albumModel)
                }
                
                if assetCollection.assetCollectionSubtype == .smartAlbumUserLibrary {
                    self?.userLibrary = assetCollection
                }
            })
            
            let userAssetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            
            userAssetCollections.enumerateObjects({ (assetCollection, idx, info) in
                let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
                
                if assets.count != 0 {
                    let albumModel = LYAutoAlbumModel()
                    albumModel.assetCollection = assetCollection
                    self?.array.append(albumModel)
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if let userLibrary = self?.userLibrary {
                    self?.gotoOneAlbum(assetCollection: userLibrary, animated: false)
                }
                
                self?.tableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("albums view controller dealloc")
    }
    
    @objc fileprivate func goBack(_ item: UIBarButtonItem) {
        block(nil)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UITableViewDelegate
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LYAutoAlbumCellId") as! LYAutoAlbumCell
        
        let cellModel = array[indexPath.row]
        
        if cellModel.image == nil {
            let assets = PHAsset.fetchAssets(in: cellModel.assetCollection, options: nil)
            let asset = assets.lastObject
            
            cellModel.title = cellModel.assetCollection.localizedTitle!
            cellModel.count = assets.count
            cellModel.image = asset?.getTumAssetImage()
        }
        
        cell.albumTitle.text = cellModel.title
        cell.albumCount.text = String(cellModel.count)
        cell.albumImage.image = cellModel.image
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let assetCollection = array[indexPath.row].assetCollection
        gotoOneAlbum(assetCollection: assetCollection!, animated: true)
    }
    
    fileprivate func gotoOneAlbum(assetCollection: PHAssetCollection, animated: Bool) {
        let pvc = LYAutoPhotosController(nibName: "LYAutoPhotosController", bundle: Bundle(for: LYAutoPhotoPickers.self))
        pvc.assetCollection = assetCollection
        pvc.maxSelects = maxSelects
        pvc.isRateTailor = isRateTailor
        pvc.tailoringRate = tailoringRate
        pvc.block = block
        navigationController?.pushViewController(pvc, animated: animated)
    }

}
