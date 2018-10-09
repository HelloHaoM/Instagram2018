//
//  LikeFeedCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

class LikeFeedCell: UICollectionViewCell {
    
    static var cellId = "LikeFeedCell"
    
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
    
    private lazy var smallPostPicture: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled  = true
        return iv
    }()
    
    private var user : User?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let padding = CGFloat(5)
    
    func layoutSubviews(_ user: User, _ date: Date, _ post : Post) {
        self.user = user
        super.layoutSubviews()
        addSubview(profilePicture)
        addSubview(message)
        addSubview(smallPostPicture)
        
        // load data on view
        if let profileUrl = user.profileImageUrl {
            profilePicture.loadImage(urlString: profileUrl)
        }
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUserTap)))
        
        let formattedString = NSMutableAttributedString()
        formattedString.activityBold(user.username)
        formattedString.activityNormal(" likes your post. ")
        formattedString.activityGray(date.timeAgoDisplay())
        message.attributedText = formattedString
        smallPostPicture.loadImage(urlString: post.imageUrl)
        
        // Set up constraints
        profilePicture.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: message.leftAnchor,
                              paddingTop: padding, paddingLeft: padding, paddingBottom: padding, paddingRight: padding,
                              width: 40, height: 40)
        
        message.anchor(top: topAnchor, left: profilePicture.rightAnchor, bottom: bottomAnchor, right: smallPostPicture.leftAnchor,
                       paddingTop: padding, paddingLeft: padding, paddingBottom: padding, paddingRight: padding)
        
        smallPostPicture.anchor(top: topAnchor, left: message.rightAnchor, bottom: bottomAnchor, right: rightAnchor,
                                paddingTop: padding, paddingLeft: padding, paddingBottom: padding, paddingRight: padding,
                                width: 40, height: 40)
        
    }
    
    @objc func handleUserTap(){
        self.delegate?.didTapUser(user: user!)
    }
    
}
