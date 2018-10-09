//
//  Comment.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation

struct Comment {
    
    let user: User
    let text: String
    let creationDate: Date
    let uid: String
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        
        let secondsFrom1970 = dictionary["creationDate"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
        
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
