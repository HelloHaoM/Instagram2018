//
//  UserProfileController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: HomePostCellViewController {
    
    /// the current user
    var user: User? {
        didSet {
            configureUser()
        }
    }
    
    /// the profile header
    private var header: UserProfileHeader?
    
    /// the pop up window
    private let alertController: UIAlertController = {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        return ac
    }()
    
    private var isGridView: Bool = true
    private var isBookMark: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil,
                                                           action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh),
                                               name: NSNotification.Name.updateUserProfileFeed,
                                               object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                 withReuseIdentifier: UserProfileHeader.headerId)
        collectionView?.register(UserProfilePhotoGridCell.self,
                                 forCellWithReuseIdentifier: UserProfilePhotoGridCell.cellId)
        collectionView?.register(HomePostCell.self,
                                 forCellWithReuseIdentifier: HomePostCell.cellId)
        collectionView?.register(UserProfileEmptyStateCell.self,
                                 forCellWithReuseIdentifier: UserProfileEmptyStateCell.cellId)
        collectionView?.register(UserProfileBookMarkCell.self,
                                 forCellWithReuseIdentifier: UserProfileBookMarkCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        configureAlertController()
    }
    
    /// cofigure the alert controller
    private func configureAlertController() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // add log out option
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out:", err)
            }
        }
        alertController.addAction(logOutAction)
        
        // add delete account option
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive,
                                                handler: nil)
        alertController.addAction(deleteAccountAction)
    }
    
    /// configure the user information
    private func configureUser() {
        guard let user = user else { return }
        
        if user.uid == Auth.auth().currentUser?.uid {
            // in the self profile page
            navigationItem.rightBarButtonItem =
                UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal),
                                                                style: .plain, target: self,
                                                                action: #selector(handleSettings))
        } else {
            // in the other user profile page
            let optionsButton = UIBarButtonItem(title: "•••", style: .plain, target: nil,
                                                action: nil)
            optionsButton.tintColor = .black
            navigationItem.rightBarButtonItem = optionsButton
        }
        
        navigationItem.title = user.username
        header?.user = user
        
        handleRefresh()
    }
    
    @objc private func handleSettings() {
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRefresh() {
        guard let uid = user?.uid else { return }
        
        posts.removeAll()

        Database.database().fetchAllPosts(withUID: uid, completion: { (posts) in
            self.posts = posts
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
            
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
        
        header?.reloadData()
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - section: the index of the items
    /// - Returns: the count of post
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if posts.count == 0 {
            return 1
        }
        return posts.count
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - indexPath: the index of the items
    /// - Returns: each post cell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0 && !isBookMark {
            // load the empty state cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserProfileEmptyStateCell.cellId,
                for: indexPath)
            return cell
        }
        
        //        if indexPath.item == posts.count - 1, !isFinishedPaging {
        //            paginatePosts()
        //        }
        
        if isGridView {
            // load the grid view cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserProfilePhotoGridCell.cellId,
                for: indexPath) as! UserProfilePhotoGridCell
            cell.post = posts[indexPath.item]
            return cell
        }
        
        if isBookMark {
            // load the bookmark cell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserProfileBookMarkCell.cellId,
                for: indexPath)
            return cell
        }
        
        // load the home post cell
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomePostCell.cellId,
            for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    /// override the collectionview function when the view is loaded to load the header
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - kind: the kind
    ///   - indexPath: the index of the items
    /// - Returns: the header
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        if header == nil {
            header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: UserProfileHeader.headerId, for: indexPath)
                as? UserProfileHeader
            header?.delegate = self
            header?.user = user
        }
        return header!
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    /// override the collection view function to get different size of cell
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - collectionViewLayout: the layout of the collection view
    ///   - indexPath: the index of items
    /// - Returns: the CGSize
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0 && !isBookMark {
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }
        
        if isBookMark {
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }
        
        if isGridView && !isBookMark {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            let dummyCell = HomePostCell(frame: CGRect(x: 0, y: 0, width: view.frame.width,
                                                       height: 1000))
            dummyCell.post = posts[indexPath.item]
            dummyCell.layoutIfNeeded()
            
            var height: CGFloat = dummyCell.header.bounds.height
            height += view.frame.width
            height += 24 + 2 * dummyCell.padding //bookmark button + padding
            height += dummyCell.captionLabel.intrinsicContentSize.height + 8
            
            //TODO: unsure why this is needed
            height += 8
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    /// override the collection view function to reszie
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - collectionViewLayout: the layout of the collection view
    ///   - section: the section
    /// - Returns: the CGSize
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

//MARK: - UserProfileHeaderDelegate

extension UserProfileController: UserProfileHeaderDelegate {
    
    func didChangeToGridView() {
        isGridView = true
        isBookMark = false
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        isBookMark = false
        collectionView?.reloadData()
    }
    
    func didChangeToBookMarkView() {
        isGridView = false
        isBookMark = true;
        collectionView?.reloadData()
    }
}


