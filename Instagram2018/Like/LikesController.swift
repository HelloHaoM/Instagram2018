//
//  LikesController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/7.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase

class LikesController: UICollectionViewController {
    
    var post: Post? {
        didSet {
            fetchLikes()
        }
    }
    
    //model name: Like
    private var likedUsers = [User]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Likes"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(LikeCell.self, forCellWithReuseIdentifier: LikeCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchLikes), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc private func fetchLikes() {
        guard let postId = post?.id else { return }
        collectionView?.refreshControl?.beginRefreshing()
        //add db fetch function
        Database.database().userOfLikesForPost(withId: postId, completion: { (users) in
            self.likedUsers = users
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeCell.cellId, for: indexPath) as! LikeCell
        cell.likedUser = likedUsers[indexPath.item]
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension LikesController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dummyCell = LikeCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        dummyCell.likedUser = likedUsers[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
}


//MARK: - LikeCellDelegate

extension LikesController: LikeCellDelegate {
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}


