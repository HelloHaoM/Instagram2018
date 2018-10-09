//
//  FollowFeedCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

class FollowFeedCell: UICollectionViewCell {
    
    static var cellId = "FollowFeedCell"
    
    var delegate: FeedCellDelegate?
    
    private lazy var profilePicture: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "user")
        iv.isUserInteractionEnabled  = true
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 40 / 2
        return iv
    }()
    
    private lazy var message: UITextView = {
        let txt = UITextView()
        txt.isUserInteractionEnabled = false
        return txt
    }()
    
    private var user : User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let padding = CGFloat(5)
    
    func layoutSubviews(_ user: User, _ date: Date) {
        self.user = user
        super.layoutSubviews()
        addSubview(profilePicture)
        addSubview(message)
        
        // load data on view
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))
        if let profileUrl = user.profileImageUrl {
            profilePicture.loadImage(urlString: profileUrl)
        }
        
        let formattedString = NSMutableAttributedString()
        formattedString.activityBold(user.username)
        formattedString.activityNormal(" started following you. ")
        formattedString.activityGray(date.timeAgoDisplay())
        message.attributedText = formattedString
        
        // Set up constraints
        profilePicture.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: message.leftAnchor,
                              paddingTop: padding, paddingLeft: padding, paddingBottom: padding, paddingRight: padding,
                              width: 40, height: 40)
        
        message.anchor(top: topAnchor, left: profilePicture.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                       paddingTop: padding, paddingLeft: padding, paddingBottom: padding, paddingRight: padding)
    }
    
    @objc func handleUserTap(){
        self.delegate?.didTapUser(user: user!)
    }
    
}

