//
//  ActivityController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ActivityController: UICollectionViewController {
    
    // Switch between two pages
    private var isFollowingPage : Bool = false
    
    // You Page - Right hand side
    private var userFeeds = [Feed]()
    
    // Following Page - Left hand side
    private var posts = [Post]()
    
    var image: UIImage!
    
    private lazy var followingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Following", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleChangeToFollowing), for: .touchUpInside)
        return button
    }()
    
    private lazy var youButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("You", for: .normal)
        button.addTarget(self, action: #selector(handleChangeToYouPage), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.cellId)
        setupNavigationAndRefreshControl()
        followingButton.setTitleColor(.gray, for: .normal)
        youButton.setTitleColor(.black, for: .normal)
        isFollowingPage = false
        handleRefresh()
        fetchFollowingUserPosts()
    }
    
    private func setupNavigationAndRefreshControl() {
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        let stackView = UIStackView(arrangedSubviews: [followingButton, youButton])
        stackView.distribution = .fillEqually
        navigationItem.titleView = navView
        navView.addSubview(stackView)
        stackView.anchor(top: navView.topAnchor, left: navView.leftAnchor, bottom: navView.bottomAnchor, right: navView.rightAnchor,
                         paddingTop: 3, paddingLeft: 3, paddingBottom: 3, paddingRight: 3)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(EmptyActivityCell.self, forCellWithReuseIdentifier: EmptyActivityCell.cellId)
        collectionView?.register(FollowFeedCell.self, forCellWithReuseIdentifier: FollowFeedCell.cellId)
        collectionView?.register(LikeFeedCell.self, forCellWithReuseIdentifier: LikeFeedCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    private func fetchFollowingUserPosts() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        collectionView?.refreshControl?.beginRefreshing()
        Database.database().reference().child("following").child(currentLoggedInUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            userIdsDictionary.forEach({ (uid, value) in
                Database.database().fetchAllPosts(withUID: uid, completion: { (posts) in
                    self.posts.append(contentsOf: posts)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    self.collectionView?.reloadData()
                    self.collectionView?.refreshControl?.endRefreshing()
                }, withCancel: { (err) in
                    self.collectionView?.refreshControl?.endRefreshing()
                })
            })
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func handleChangeToFollowing() {
        followingButton.setTitleColor(.black, for: .normal)
        youButton.setTitleColor(.gray, for: .normal)
        isFollowingPage = true
        collectionView?.reloadData()
    }
    
    @objc private func handleChangeToYouPage() {
        followingButton.setTitleColor(.gray, for: .normal)
        youButton.setTitleColor(.black, for: .normal)
        isFollowingPage = false
        collectionView?.reloadData()
    }
    
    @objc private func handleRefresh() {
        if (isFollowingPage) {
            posts.removeAll()
            fetchFollowingUserPosts()
        }else{
            userFeeds.removeAll()
            self.collectionView?.refreshControl?.beginRefreshing()
            Database.database().fetchCurrentUserFeeds(completion: {(feed) in
                self.userFeeds = feed
                self.userFeeds.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
            })
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFollowingPage {
            if posts.count == 0 {
                return 1
            }
            return posts.count
        } else {
            if userFeeds.count == 0 {
                return 1
            }
            return userFeeds.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isFollowingPage {
            if posts.count == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyActivityCell.cellId, for: indexPath)
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as! HomePostCell
            if indexPath.item < posts.count {
                cell.post = posts[indexPath.item]
            }
            cell.delegate = self
            return cell
        } else {
            if userFeeds.count == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyActivityCell.cellId, for: indexPath)
                return cell
            }
            let feed = userFeeds[indexPath.item]
            switch(feed.type){
            case .follow:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowFeedCell.cellId, for: indexPath) as! FollowFeedCell
                cell.delegate = self
                cell.layoutSubviews(feed.user,feed.creationDate)
                return cell
            case .like(let post):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeFeedCell.cellId, for: indexPath) as! LikeFeedCell
                cell.delegate = self
                cell.layoutSubviews(feed.user,feed.creationDate,post)
                return cell
            }
        }
    }
}


protocol FeedCellDelegate {
    func didTapUser(user: User)
    func didTapPost(post: Post)
    func didPressFollow(user: User)
}

extension ActivityController : FeedCellDelegate {
    
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func didTapPost(post: Post) {
        
    }
    
    func didPressFollow(user: User) {
        
    }
    
}

extension ActivityController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isFollowingPage {
            if posts.count == 0 {
                let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
                return CGSize(width: view.frame.width, height: emptyStateCellHeight)
            }
            
            let dummyCell = HomePostCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
            dummyCell.post = posts[indexPath.item]
            dummyCell.layoutIfNeeded()
            var height: CGFloat = dummyCell.header.bounds.height
            height += view.frame.width
            height += 24 + 2 * dummyCell.padding //bookmark button + padding
            height += dummyCell.captionLabel.intrinsicContentSize.height + 8
            return CGSize(width: view.frame.width, height: height + 5)
            
        } else {
            if userFeeds.count == 0 {
                let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
                return CGSize(width: view.frame.width, height: emptyStateCellHeight)
            }
            return CGSize(width: view.frame.width, height: 50)
        }
    }
    
}

extension NSMutableAttributedString {
    @discardableResult func activityBold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica-Bold", size: 14)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func activityNormal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica", size: 14)!]
        let normal = NSAttributedString(string: text, attributes:attrs)
        append(normal)
        return self
    }
    
    @discardableResult func activityGray(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Helvetica", size: 12)!, .foregroundColor: UIColor.gray]
        let normal = NSAttributedString(string: text, attributes:attrs)
        append(normal)
        return self
    }
}


extension ActivityController: HomePostCellDelegate {
    
    func didTapLike(post: Post) {
        let likesController = LikesController(collectionViewLayout: UICollectionViewFlowLayout())
        likesController.post = post
        navigationController?.pushViewController(likesController, animated: true)
    }
    
    //MARK: - HomePostCellDelegate
    func didBrowse() {
        //present(HomePostCellViewController.browser, animated: true, completion: nil)
        let inRangeController = InRangeController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(inRangeController, animated: true)
    }
    
    func didSend(image: UIImage){
        print("Send Button Click")
        self.image = image
        present(HomePostCellViewController.browser, animated: true, completion: nil)
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    
    func didTapOptions(post: Post) {
        guard (Auth.auth().currentUser?.uid) != nil else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if let unfollowAction = unfollowAction(forPost: post) {
            alertController.addAction(unfollowAction)
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func unfollowAction(forPost post: Post) -> UIAlertAction? {
        let action = UIAlertAction(title: "Unfollow", style: .destructive) { (_) in
            let uid = post.user.uid
            Database.database().unfollowUser(withUID: uid, completion: { (_) in
                let filteredPosts = self.posts.filter({$0.user.uid != uid})
                self.posts = filteredPosts
                self.collectionView?.reloadData()
            })
        }
        return action
    }
    
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var post = posts[indexPath.item]
        
        if post.likedByCurrentUser {
            Database.database().reference().child("likes").child(post.id).child(uid).removeValue { (err, _) in
                if let err = err {
                    print("Failed to unlike post:", err)
                    return
                }
                post.likedByCurrentUser = false
                post.likes = post.likes - 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
            }
        } else {
            let values = [uid : 1]
            Database.database().reference().child("likes").child(post.id).updateChildValues(values) { (err, _) in
                if let err = err {
                    print("Failed to like post:", err)
                    return
                }
                post.likedByCurrentUser = true
                post.likes = post.likes + 1
                self.posts[indexPath.item] = post
                UIView.performWithoutAnimation {
                    self.collectionView?.reloadItems(at: [indexPath])
                }
                
                // record like feed
                guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
                let feedRef = Database.database().reference().child("feed").child(post.user.uid).childByAutoId()
                let feedValue = ["type": Feed.likeType,
                                 "user": currentLoggedInUserId,
                                 "post": post.id,
                                 "creationDate": Date().timeIntervalSince1970] as [String : Any]
                feedRef.updateChildValues(feedValue)
            }
        }
    }
}


