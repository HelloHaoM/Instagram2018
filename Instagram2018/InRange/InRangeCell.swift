//
//  InRangeCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import UIKit

class InRangeCell: UICollectionViewCell {
    
    var username: String? {
        didSet {
            usernameLabel.text = username
        }
    }
    
    var sentImage: UIImage? {
        didSet {
            sentImageView.image = sentImage
        }
    }
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let sentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "user")
        imageView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        imageView.layer.borderWidth = 0
        imageView.frame = CGRect(x: 85, y: 20, width: 150, height: 150)
        return imageView
    }()
    
    static var cellId = "inRangerCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /// init the in range cell
    private func sharedInit() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, width: 70)
        
        addSubview(sentImageView)
        sentImageView.anchor(top: topAnchor, left: usernameLabel.rightAnchor, bottom: bottomAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 10, width: 150, height: 150)
        sentImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        addSubview(separatorView)
        separatorView.anchor(left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 0.5)
    }
}

