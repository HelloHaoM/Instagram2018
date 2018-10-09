//
//  HomeController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase
import MultipeerConnectivity

class HomeController: HomePostCellViewController {
    
    private let alertController: UIAlertController = {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        return ac
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMultipeer()
        
        configureNavigationBar()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.cellId)
        collectionView?.backgroundView = HomeEmptyStateView()
        collectionView?.backgroundView?.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateHomeFeed, object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        fetchAllPosts()
        
        configureAlertController()
    }
    
    private func configureAlertController() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let sortByTimeAction = UIAlertAction(title: "Sort by time", style: .default) { (_) in
            do {
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.collectionView?.reloadData()
            }
            
        }
        alertController.addAction(sortByTimeAction)
        
        let sortByLocationAction = UIAlertAction(title: "Sort by location", style: .default) { (_) in
            do {
                //TODO: fake sort, need to do sort by location (now is sort by time ascending)
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedAscending
                })
                
                self.collectionView?.reloadData()

            }
        }
        alertController.addAction(sortByLocationAction)
    }
    
    private func configureNavigationBar() {
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo").withRenderingMode(.alwaysOriginal))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
        let inRangeButton = UIBarButtonItem(image: #imageLiteral(resourceName: "people_near").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleInRange))
        let sortButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(handleSort))
        navigationItem.rightBarButtonItems = [sortButton, inRangeButton]
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "inbox").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
    }
    
    private func fetchAllPosts() {
        showEmptyStateViewIfNeeded()
        fetchPostsForCurrentUser()
        fetchFollowingUserPosts()
    }
    
    private func fetchPostsForCurrentUser() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchAllPosts(withUID: currentLoggedInUserId, completion: { (posts) in
            self.posts.append(contentsOf: posts)
            
            //post sort function
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    private func fetchFollowingUserPosts() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().reference().child("following").child(currentLoggedInUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else { return }
            
            userIdsDictionary.forEach({ (uid, value) in
                
                Database.database().fetchAllPosts(withUID: uid, completion: { (posts) in
                    
                    self.posts.append(contentsOf: posts)
                    
                    //post sort function
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
    
    override func showEmptyStateViewIfNeeded() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        Database.database().numberOfFollowingForUser(withUID: currentLoggedInUserId) { (followingCount) in
            Database.database().numberOfPostsForUser(withUID: currentLoggedInUserId, completion: { (postCount) in
                
                if followingCount == 0 && postCount == 0 {
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
                        self.collectionView?.backgroundView?.alpha = 1
                    }, completion: nil)
                    
                } else {
                    self.collectionView?.backgroundView?.alpha = 0
                }
            })
        }
    }
    
    @objc private func handleRefresh() {
        posts.removeAll()
        fetchAllPosts()
    }
    
    @objc private func handleSort() {
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleCamera() {
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    @objc private func handleInRange() {
        let inRangeController = InRangeController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(inRangeController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as! HomePostCell
        if indexPath.item < posts.count {
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dummyCell = HomePostCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
        dummyCell.post = posts[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        var height: CGFloat = dummyCell.header.bounds.height
        height += view.frame.width
        height += 24 + 2 * dummyCell.padding //bookmark button + padding
        height += dummyCell.captionLabel.intrinsicContentSize.height + 8
        return CGSize(width: view.frame.width, height: height)
    }
}

