//
//  LikeCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/7.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

protocol LikeCellDelegate {
    func didTapUser(user: User)
}

class LikeCell: UICollectionViewCell {
    
    //model name: Like
    var likedUser: User? {
        didSet {
            configureLike()
        }
    }
    
    var delegate: LikeCellDelegate?
    
    private let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        iv.image = #imageLiteral(resourceName: "user")
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    static var cellId = "likeCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, paddingLeft: 8, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 50 / 2
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        addSubview(separatorView)
        separatorView.anchor(left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.5)
    }
    
    private func configureLike() {
        guard let likedUser = likedUser else { return }
        
        usernameLabel.text = likedUser.username
        
        if let profileImageUrl = likedUser.profileImageUrl {
            profileImageView.loadImage(urlString: profileImageUrl)
        } else {
            profileImageView.image = #imageLiteral(resourceName: "user")
        }
        
    }
    
    @objc private func handleTap() {
        guard let likedUser = likedUser else { return }
        
        delegate?.didTapUser(user: likedUser)
    }
}


