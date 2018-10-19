//
//  EmptySearchCell.swift
//  Instagram2018
//
//  Created by wry on 2018/10/20.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  ViewController for showing the empty when the users are empty

import UIKit

class EmptySearchCell: UICollectionViewCell {
    
    static var cellId = "EmptySearchCell"
    
    private let noUserLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "There is no user to display yet."
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(noUserLabel)
        noUserLabel.anchor(top: topAnchor, left: leftAnchor,
                           bottom: bottomAnchor, right: rightAnchor)
    }
    
}
