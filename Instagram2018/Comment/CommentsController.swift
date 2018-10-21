//
//  CommentsController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  Main ViewController for "Comments" page

import UIKit
import Firebase

class CommentsController: UICollectionViewController {
    
    //set comments information of a post
    var post: Post? {
        didSet {
            fetchComments()
        }
    }
    //initiate a "Comment" type instance
    private var comments = [Comment]()
    
    private lazy var commentInputAccessoryView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let commentInputAccessoryView = CommentInputAccessoryView(frame: frame)
        commentInputAccessoryView.delegate = self
        return commentInputAccessoryView
    }()
    
    override var canBecomeFirstResponder: Bool { return true }
    
    override var inputAccessoryView: UIView? { return commentInputAccessoryView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.register(CommentCell.self,
                                 forCellWithReuseIdentifier: CommentCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchComments), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //when this page is shown, hide the tab bar
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //when this page is disappered, show the tab bar
        tabBarController?.tabBar.isHidden = false
    }
    
    // get comments information for a specific post
    @objc private func fetchComments() {
        guard let postId = post?.id else { return }
        collectionView?.refreshControl?.beginRefreshing()
        Database.database().fetchCommentsForPost(withId: postId, completion: { (comments) in
            self.comments = comments
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    //override numberOfItemsInSection method
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    //override cellForItemAt method
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommentCell.cellId, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension CommentsController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dummyCell = CommentCell(frame: CGRect(
            x: 0, y: 0, width: view.frame.width, height: 50))
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
}

//MARK: - CommentInputAccessoryViewDelegate

extension CommentsController: CommentInputAccessoryViewDelegate {
    func didSubmit(comment: String) {
        guard let postId = post?.id else { return }
        //when submmiting, save comment information into the database
        Database.database().addCommentToPost(withId: postId, text: comment) { (err) in
            if err != nil {
                return
            }
            self.commentInputAccessoryView.clearCommentTextField()
            self.fetchComments()
        }
    }
}

//MARK: - CommentCellDelegate

extension CommentsController: CommentCellDelegate {
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(
            collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}

