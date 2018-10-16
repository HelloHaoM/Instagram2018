//
//  UserSearchController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {
    
    /// a flag to identify which page
    private var isSuggestedPage: Bool = false;
    
    private var header: UserSearchHeader?
    
    /// the search bar
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return sb
    }()
    
    /// the current user
    var user: User?
    
    /// the group of users need to be shown
    private var users = [User]()
    private var suggestedUsers = [User]()
    private var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = searchBar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.register(UserSearchHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserSearchHeader.headerId)
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: UserSearchCell.cellId)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        searchBar.delegate = self
        
        // fetch all user
        fetchAllUsers()
        // fetch all suggested user
        fetchSuggestedUsers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView?.width(UIScreen.main.bounds.width)
        navigationItem.titleView?.height(44)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.width(UIScreen.main.bounds.width)
        navigationItem.titleView?.height(44)
    }
    
    /// get all users from the database
    private func fetchAllUsers() {
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchAllUsers(includeCurrentUser: false, completion: { (users) in
            self.users = users
            self.filteredUsers = users
            self.searchBar.text = ""
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (_) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    /// get all suggested user from the database
    private func fetchSuggestedUsers() {
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchSuggestedUsers(currentUser: user, includeCurrentUser: false, completion: { (users) in
            self.suggestedUsers = users
            //self.filteredUsers = users
            self.searchBar.text = ""
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }) { (_) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func handleRefresh() {
        fetchAllUsers()
        fetchSuggestedUsers()
    }
    
    /// override the collectionview function when item is selected
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - indexPath: the index of items
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = filteredUsers[indexPath.item]
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - section: the index of the items
    /// - Returns: the count of filteruser number
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Apply serach filter when reload to isSuggested page or ordinary page
        if isSuggestedPage && self.searchBar.text == "" {
            filteredUsers = suggestedUsers
        } else if !isSuggestedPage && self.searchBar.text == "" {
            filteredUsers = users
        } else if isSuggestedPage && self.searchBar.text != ""{
            filteredUsers = suggestedUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(self.searchBar.text!.lowercased())
            }
        } else if !isSuggestedPage && self.searchBar.text != ""{
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.lowercased().contains(self.searchBar.text!.lowercased())
            }
        }
        return filteredUsers.count
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - indexPath: the index of the items
    /// - Returns: each user cell
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSearchCell.cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if header == nil {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserSearchHeader.headerId, for: indexPath) as? UserSearchHeader
            header?.delegate = self
        }
        return header!
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    /// override the collectionview function to resize the frame
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - collectionViewLayout: the layout of the collection view
    ///   - indexPath: the index of the itmes
    /// - Returns: the CGSize
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 30)
    }
}

//MARK: - UISearchBarDelegate

extension UserSearchController: UISearchBarDelegate {
    /// filter the user according to the search text
    ///
    /// - Parameters:
    ///   - searchBar: the search bar
    ///   - searchText: the search text
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty && !isSuggestedPage {
            filteredUsers = users
        } else if searchText.isEmpty && isSuggestedPage {
            filteredUsers = suggestedUsers
        } else if isSuggestedPage {
            filteredUsers = suggestedUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//MARK: - UserProfileHeaderDelegate

extension UserSearchController: UserSearchHeaderDelegate {
    
    func didChangeToAll() {
        isSuggestedPage = false
        if(users.isEmpty){
            fetchAllUsers()
        }
        collectionView?.reloadData()
    }
    
    func didChangeToSuggested() {
        isSuggestedPage = true
        if(suggestedUsers.isEmpty){
            fetchSuggestedUsers()
        }
        collectionView?.reloadData()
    }
    
}

