//
//  UserProfileBookMarkCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

class UserProfileBookMarkCell: UICollectionViewCell {
    
    private let bookMarkImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "user")
        iv.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        iv.layer.borderWidth = 0.5
        return iv
    }()
    
    private let noBookMarksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "No BookMark Yet."
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    static var cellId = "userProfileBookMarkCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /// init the bookmark view
    private func sharedInit() {
        addSubview(noBookMarksLabel)
        noBookMarksLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}

