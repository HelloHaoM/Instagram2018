//
//  Post.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  Post Model, including
//  user who did the post, image Url, caption of the post, address information,
//  location(coordinates) information, and create date of the post

import Foundation

struct Post {
    
    var id: String
    
    let user: User
    let imageUrl: String
    let caption: String
    let address: String
    let location: [Double]
    let creationDate: Date
    
    var likes: Int = 0
    var likedByCurrentUser = false
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.address = dictionary["address"] as? String ?? ""
        self.location = dictionary["location"] as? [Double] ?? []
        self.id = dictionary["id"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
