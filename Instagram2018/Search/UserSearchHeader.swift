//
//  UserSearchHeader.swift
//  Instagram2018
//
//  Created by wry on 2018/10/16.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  ViewController for the header part of search page, including
//  "All" and "Suggested" button and its mothod to handle page switching

import UIKit
import Firebase

protocol UserSearchHeaderDelegate {
    func didChangeToAll()
    func didChangeToSuggested()
}

//MARK: - UserSearchHeader

class UserSearchHeader: UICollectionViewCell {
    
    var delegate: UserSearchHeaderDelegate?
    
    /// all user infromation button
    private lazy var allUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("All", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleChangeToAll),
                         for: .touchUpInside)
        return button
    }()
    
    /// suggested user button
    private lazy var suggestedUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Suggested", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.addTarget(self, action: #selector(handleChangeToSuggested),
                         for: .touchUpInside)
        return button
    }()
    
    
    private let padding: CGFloat = 12
    
    static var headerId = "userSearchHeaderId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /// init the user profile header
    private func sharedInit() {
        
        let stackView = UIStackView(arrangedSubviews: [allUserButton,
                                                       suggestedUserButton])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                         height: 30)

    }
    
    
    @objc private func handleChangeToAll() {
        allUserButton.setTitleColor(.black, for: .normal)
        suggestedUserButton.setTitleColor(.gray, for: .normal)

        delegate?.didChangeToAll()
    }
    
    @objc private func handleChangeToSuggested() {
        allUserButton.setTitleColor(.gray, for: .normal)
        suggestedUserButton.setTitleColor(.black, for: .normal)
        delegate?.didChangeToSuggested()
    }
    
}



