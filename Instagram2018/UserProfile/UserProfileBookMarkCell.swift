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
    
    private func sharedInit() {
        //        addSubview(bookMarkImageView)
        //        bookMarkImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 120, paddingLeft: 168, width: 80, height: 80)
        //        bookMarkImageView.layer.cornerRadius = 80 / 2
        //
        //        addSubview(noBookMarksLabel)
        //        noBookMarksLabel.anchor(top: bookMarkImageView.bottomAnchor, left: leftAnchor, paddingTop: 230, paddingLeft: 153)
        addSubview(noBookMarksLabel)
        noBookMarksLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}

