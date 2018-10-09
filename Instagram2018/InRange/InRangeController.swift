//
//  InRangeController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit


class InRangeController: UICollectionViewController {
    
    private var senderNames = [String]()
    private var senderImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "In Range"
        let backButtonitem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButtonitem
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.register(InRangeCell.self, forCellWithReuseIdentifier: InRangeCell.cellId)
        
        updateData()
        
        //        senderNames.append("test")
        //        senderImages.append(#imageLiteral(resourceName: "user"))
        
    }
    
    func updateData() {
        self.senderNames = MultiPeerUtilties.senderNames
        self.senderImages = MultiPeerUtilties.senderImages
    }
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return senderImages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InRangeCell.cellId, for: indexPath) as! InRangeCell
        cell.username = senderNames[indexPath.item]
        cell.sentImage = senderImages[indexPath.item]
        return cell
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout

extension InRangeController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 150)
    }
}

