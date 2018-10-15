//
//  UserProfileEmptyStateCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

class UserProfileEmptyStateCell: UICollectionViewCell {
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "No posts yet."
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    static var cellId = "userProfileEmptyStateCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /// init the empty state view
    private func sharedInit() {
        addSubview(noPostsLabel)
        noPostsLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}

