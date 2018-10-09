//
//  Feed.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation

enum FeedType {
    case follow
    case like(Post)
}

struct Feed {
    
    static let followType = 1
    static let likeType = 2
    
    let user: User
    let creationDate: Date
    let type: FeedType
}

