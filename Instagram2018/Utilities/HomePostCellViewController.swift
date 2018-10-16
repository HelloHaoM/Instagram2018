//
//  HomePostCellViewController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase
import MultipeerConnectivity
import FWPopupView

class HomePostCellViewController: UICollectionViewController, HomePostCellDelegate, MCBrowserViewControllerDelegate, MCSessionDelegate, AlertProtocol {
    
    let serviceType = "InstagramClone"
    
    static var browser: MCBrowserViewController!
    static var assistant: MCAdvertiserAssistant!
    static var session: MCSession!
    static var peerID: MCPeerID!
    
    var image: UIImage!
    
    var posts = [Post]()
    
    func showEmptyStateViewIfNeeded() {}
    
    // MARK MultipeerConnectivity
    
    /// init the multipeer
    func initMultipeer() {
        if HomePostCellViewController.peerID == nil {
            // set the id
            HomePostCellViewController.peerID = MCPeerID(displayName: UIDevice.current.name)
        }
        
        if HomePostCellViewController.session == nil {
            // set the session
            HomePostCellViewController.session = MCSession(peer: HomePostCellViewController.peerID)
            HomePostCellViewController.session.delegate = self
        }
        
        if HomePostCellViewController.browser == nil {
            // set the browser
            HomePostCellViewController.browser = MCBrowserViewController(serviceType: serviceType, session: HomePostCellViewController.session)
            HomePostCellViewController.browser.delegate = self
        }
        
        if HomePostCellViewController.assistant == nil {
            // set the advertiser
            HomePostCellViewController.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: HomePostCellViewController.session)
            HomePostCellViewController.assistant.start()
        }
    }
    
    /// do something when click done on browser
    ///
    /// - Parameter browserViewController: the controller of the browser view
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
        let imageData = image.pngData()
        // try to sent a imgae data
        do {
            try HomePostCellViewController.session.send(imageData!, toPeers: HomePostCellViewController.session.connectedPeers, with: MCSessionSendDataMode.unreliable)
            print("Image Data Sent")
            createAlertWithMsgAndTitle("Success", msg: "Photo sent to \(HomePostCellViewController.session.connectedPeers.description)")
            
        } catch let error as NSError {
            createAlertWithMsgAndTitle("Error", msg: error.localizedDescription)
        }
    }
    
    /// do something when click cancel on browser
    ///
    /// - Parameter browserViewController: <#browserViewController description#>
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("didChange")
    }
    
    /// do something when receive data
    ///
    /// - Parameters:
    ///   - session: the session
    ///   - data: the data
    ///   - peerID: the sender peerID
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("receiving data")
        DispatchQueue.main.async(execute: {
            
            MultiPeerUtilties.appendData(name: peerID.displayName, image: UIImage(data: data))
            
            let imageView = UIImageView(image: UIImage(data: data))
            imageView.frame = CGRect(x: 85, y: 20, width: 100, height: 100)
            
            // 1: tocuh outside will disppear
            let vProperty = FWAlertViewProperty()
            vProperty.touchWildToHide = "0"
            
            // set up the pop up window
            let block: FWPopupItemClickedBlock = { (popupView, index, title) in
                
                if index == 1 {
                    // click confirm do something
                    print("View")
                    // set up in range controller
                    let inRangeController = InRangeController(collectionViewLayout: UICollectionViewFlowLayout())
                    self.navigationController?.pushViewController(inRangeController, animated: true)
                }
            }
            let items = [FWPopupItem(title: "Confirm", itemType: .normal, isCancel: true, canAutoHide: true, itemClickedBlock: block),
                         FWPopupItem(title: "View", itemType: .normal, isCancel: false, canAutoHide: true, itemClickedBlock: block)]
            let alert = FWAlertView.alert(title: "Nearby Image", detail: "Image Sent From \(peerID.displayName)", inputPlaceholder: nil, keyboardType: .default, isSecureTextEntry: false, customView: imageView, items: items, vProperty: vProperty)
            alert.show()
        })
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    //MARK: - HomePostCellDelegate
    
    func didBrowse() {
        // set up in range controller
        let inRangeController = InRangeController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(inRangeController, animated: true)
    }
    
    func didSend(image: UIImage){
        //print("Send Button Click")
        self.image = image
        present(HomePostCellViewController.browser, animated: true, completion: nil)
    }
    
    func didTapComment(post: Post) {
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
    }
    
    func didTapLike(post: Post) {
        let likesController = LikesController(collectionViewLayout: UICollectionViewFlowLayout())
        likesController.post = post
        navigationController?.pushViewController(likesController, animated: true)
    }
    
    func didTapUser(user: User) {
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = user
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    func didTapOptions(post: Post) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if currentLoggedInUserId == post.user.uid {
            if let deleteAction = deleteAction(forPost: post) {
                alertController.addAction(deleteAction)
            }
        } else {
            if let unfollowAction = unfollowAction(forPost: post) {
                alertController.addAction(unfollowAction)
            }
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAction(forPost post: Post) -> UIAlertAction? {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return nil }
        
        let action = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            
            let alert = UIAlertController(title: "Delete Post?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) in
                
                Database.database().deletePost(withUID: currentLoggedInUserId, postId: post.id) { (_) in
                    if let postIndex = self.posts.index(where: {$0.id == post.id}) {
                        self.posts.remove(at: postIndex)
                        self.collectionView?.reloadData()
                        self.showEmptyStateViewIfNeeded()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        })
        return action
    }
    
    private func unfollowAction(forPost post: Post) -> UIAlertAction? {
        let action = UIAlertAction(title: "Unfollow", style: .destructive) { (_) in
            
            let uid = post.user.uid
            Database.database().unfollowUser(withUID: uid, completion: { (_) in
                let filteredPosts = self.posts.filter({$0.user.uid != uid})
                self.posts = filteredPosts
                self.collectionView?.reloadData()
                self.showEmptyStateViewIfNeeded()
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


