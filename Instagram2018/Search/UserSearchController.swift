//
//  UserSearchController.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  Main controller of user search page,
//  controls the page switching ("All" and "Suggested"), fetch user information,
//  setup navigation item, UserSearchHeader and UserSearchCell, and override
//  corresponding collectionView methods

import UIKit
import Firebase

class UserSearchController: UICollectionViewController {
    
    /// a flag to identify which page
    private var isSuggestedPage: Bool = false;
    
    private var header: UserSearchHeader?
    
    /// the search bar
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf:
            [UISearchBar.self]).backgroundColor = UIColor.rgb(
                red: 240, green: 240, blue: 240)
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
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.register(
            UserSearchHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: UserSearchHeader.headerId)
        collectionView?.register(
            EmptySearchCell.self, forCellWithReuseIdentifier: EmptySearchCell.cellId)
        collectionView?.register(
            UserSearchCell.self, forCellWithReuseIdentifier: UserSearchCell.cellId)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh),
                                 for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        searchBar.delegate = self
        
        // fetch all user
        fetchAllUsers()
        // fetch all suggested user
        fetchSameSexUsers()
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
    
    /// get all users from the database (not include current user)
    private func fetchAllUsers() {
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchAllUsers(includeCurrentUser: false,
                                          completion: { (users) in
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
    private func fetchSameSexUsers() {
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchSameSexUsers(
            currentUser: user, includeCurrentUser: false, completion: { (users) in
                self.suggestedUsers = users
                self.suggestedUsers.sort(by: { (user1, user2) -> Bool in
                    return user1.username.compare(user2.username) == .orderedAscending
                })
                self.searchBar.text = ""
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
        }) { (_) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    private func fetchSuggestedUsers() {
        
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchSuggestedUsers(
            currentUser: user, completion: { (users) in
                self.suggestedUsers += users
                self.suggestedUsers.sort(by: { (user1, user2) -> Bool in
                    return user1.username.compare(user2.username) == .orderedAscending
                })
                self.searchBar.text = ""
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
        }) { (_) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func handleRefresh() {
        users.removeAll()
        suggestedUsers.removeAll()
        fetchAllUsers()
        fetchSameSexUsers()
        fetchSuggestedUsers()
    }
    
    /// override the collectionview function when item is selected
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - indexPath: the index of items
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        //only when there is at least one user, activate didSelectItemAt method
        if filteredUsers.count != 0{
            searchBar.resignFirstResponder()
            let userProfileController = UserProfileController(
                collectionViewLayout: UICollectionViewFlowLayout())
            userProfileController.user = filteredUsers[indexPath.item]
            navigationController?.pushViewController(userProfileController,
                                                     animated: true)
        }
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - section: the index of the items
    /// - Returns: the count of filteruser number
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        // Apply serach filter when reload to isSuggested page or ordinary page
        if isSuggestedPage && self.searchBar.text == "" {
            filteredUsers = suggestedUsers
        } else if !isSuggestedPage && self.searchBar.text == "" {
            filteredUsers = users
        } else if isSuggestedPage && self.searchBar.text != ""{
            filteredUsers = suggestedUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(
                    self.searchBar.text!.lowercased())
            }
        } else if !isSuggestedPage && self.searchBar.text != ""{
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.lowercased().contains(
                    self.searchBar.text!.lowercased())
            }
        }
        //if there is no user, set the item number as 1 (for empty cell)
        if filteredUsers.count == 0{
            return 1
        }
        return filteredUsers.count
    }
    
    /// override the collectionview function when the view is loaded
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - indexPath: the index of the items
    /// - Returns: each user cell
    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //show empty cell if there is no user
        if isSuggestedPage && suggestedUsers.count == 0{
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptySearchCell.cellId, for: indexPath)
            return cell
        }
        //show empty cell if there is no user
        if !isSuggestedPage && users.count == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptySearchCell.cellId, for: indexPath)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserSearchCell.cellId,
            for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    //override viewForSupplementaryElementOfKind method
    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath) -> UICollectionReusableView {
        if header == nil {
            header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: UserSearchHeader.headerId,
                for: indexPath) as? UserSearchHeader
            header?.delegate = self
        }
        return header!
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    
    //set minimumInteritemSpacingForSectionAt layout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //set minimumLineSpacingForSectionAt layout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    /// override the collectionview function to resize the frame
    ///
    /// - Parameters:
    ///   - collectionView: the collection view
    ///   - collectionViewLayout: the layout of the collection view
    ///   - indexPath: the index of the itmes
    /// - Returns: the CGSize
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //set empty cell view layout
        if isSuggestedPage && suggestedUsers.count == 0{
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }
        //set empty cell view layout
        if !isSuggestedPage && users.count == 0 {
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }
        
        return CGSize(width: view.frame.width, height: 66)
        
    }
    //set referenceSizeForHeaderInSection layout
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
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

//MARK: - UserSearchHeaderDelegate

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
            fetchSameSexUsers()
            fetchSuggestedUsers()
        }
        collectionView?.reloadData()
    }
    
}

