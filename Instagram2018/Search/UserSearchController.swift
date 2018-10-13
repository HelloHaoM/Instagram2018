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
    
    private var isRecommendPage: Bool = false;
    
    private lazy var ordinaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.height(20)
        button.addTarget(self, action: #selector(handleChangeToOrdinary), for: .touchUpInside)
        return button
    }()
    
    private lazy var recommendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recommend", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.height(20)
        button.addTarget(self, action: #selector(handleChangeToRecommend), for: .touchUpInside)
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .gray
        sb.height(80)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return sb
    }()
    
    var user: User?
    
    private var users = [User]()
    private var recommendUsers = [User]()
    private var filteredUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNav()
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: UserSearchCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        searchBar.delegate = self
        
        // fetch all user
        fetchAllUsers()
        // fetch all recommend user
        fetchRecommendedUsers()
    }
    
    private func setUpNav(){
//        let navView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//        let stackView = UIStackView(arrangedSubviews: [ordinaryButton, recommendButton, searchBar])
//        stackView.distribution = .fillEqually
//        navigationItem.titleView = navView
//        navView.addSubview(stackView)
//        stackView.anchor(top: navView.topAnchor, left: navView.leftAnchor, bottom: navView.bottomAnchor, right: navView.rightAnchor, paddingTop: 3, paddingLeft: 3, paddingBottom: 3, paddingRight: 3)
        
        let buttonView = UIStackView(arrangedSubviews: [ordinaryButton, recommendButton])
        buttonView.distribution = .fillEqually
        buttonView.axis = .horizontal
        
        let searchView = UIStackView(arrangedSubviews: [buttonView, searchBar])
        searchView.axis = .vertical
        
        navigationItem.titleView = searchView
        navigationItem.titleView?.width(UIScreen.main.bounds.width)
        
        //navigationItem.titleView = searchBar
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout()
        navigationController?.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.titleView?.width(UIScreen.main.bounds.width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.titleView?.width(UIScreen.main.bounds.width)
    }
    
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
    
    private func fetchRecommendedUsers() {
        collectionView?.refreshControl?.beginRefreshing()
        
        Database.database().fetchRecommendedUsers(currentUser: user, includeCurrentUser: false, completion: { (users) in
            self.recommendUsers = users
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
        fetchRecommendedUsers()
    }
    
    @objc private func handleChangeToOrdinary() {
        ordinaryButton.setTitleColor(.black, for: .normal)
        recommendButton.setTitleColor(.gray, for: .normal)
        isRecommendPage = false
        if(users.isEmpty){
            fetchAllUsers()
        }
        
        collectionView?.reloadData()
    }
    
    @objc private func handleChangeToRecommend() {
        ordinaryButton.setTitleColor(.gray, for: .normal)
        recommendButton.setTitleColor(.black, for: .normal)
        isRecommendPage = true
        if(recommendUsers.isEmpty){
            fetchRecommendedUsers()
        }
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.user = filteredUsers[indexPath.item]
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Apply serach filter when reload to isRecommend page or ordinary page
        if isRecommendPage && self.searchBar.text == "" {
            filteredUsers = recommendUsers
        } else if !isRecommendPage && self.searchBar.text == "" {
            filteredUsers = users
        } else if isRecommendPage && self.searchBar.text != ""{
            filteredUsers = recommendUsers.filter { (user) -> Bool in
                return user.username.lowercased().contains(self.searchBar.text!.lowercased())
            }
        } else if !isRecommendPage && self.searchBar.text != ""{
            filteredUsers = users.filter { (user) -> Bool in
                return user.username.lowercased().contains(self.searchBar.text!.lowercased())
            }
        }
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSearchCell.cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension UserSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}

//MARK: - UISearchBarDelegate

extension UserSearchController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty && !isRecommendPage {
            filteredUsers = users
        } else if searchText.isEmpty && isRecommendPage {
            filteredUsers = recommendUsers
        } else if isRecommendPage {
            filteredUsers = recommendUsers.filter { (user) -> Bool in
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

