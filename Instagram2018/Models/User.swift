//
//  User.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  User Model, including
//  user id, user name, user profile image Url, and user sex

import Foundation

struct User: Equatable {
    
    let uid: String
    let username: String
    let profileImageUrl: String?
    let sex: String?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? nil
        self.sex = dictionary["sex"] as? String ?? "male"
    }
    
    static func == (user1: User, user2: User) -> Bool {
        return user1.uid == user2.uid
    }
}
