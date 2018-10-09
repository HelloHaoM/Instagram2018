//
//  FirebaseUserActivityExtensions.swift
//  Instagram2018
//
//  Created by wry on 2018/10/9.
//  Copyright © 2018年 jiacheng. All rights reserved.
//

import Foundation
import Firebase

extension Database {
    
    func fetchCurrentUserFeeds(completion: @escaping ([Feed]) -> ()){
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("feed").child(currentLoggedInUserId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if(!snapshot.exists()){
                completion([])
                return
            }
            guard let feedDictionaries = snapshot.value as? [String: Any] else { return }
            var feeds = [Feed]()
            
            for key in feedDictionaries.keys {
                let feedDictionary : Dictionary =  feedDictionaries[key] as! [String: Any]
                let creationDate = feedDictionary["creationDate"] as? Double ?? 0
                let userId = feedDictionary["user"] as! String
                let type = feedDictionary["type"] as! Int
                switch (type){
                case Feed.followType:
                    self.fetchUser(withUID: userId, completion: { (user) in
                        let feed = Feed(user: user,
                                        creationDate: Date(timeIntervalSince1970: creationDate),
                                        type: .follow)
                        feeds.append(feed)
                        if(feeds.count == feedDictionaries.count){
                            completion(feeds)
                            return
                        }
                    })
                case Feed.likeType:
                    let postId = feedDictionary["post"] as! String
                    self.fetchUser(withUID: userId, completion: { (user) in
                        self.fetchPost(withUID: currentLoggedInUserId, postId: postId, completion: { (post) in
                            let feed = Feed(user: user,
                                            creationDate: Date(timeIntervalSince1970: creationDate),
                                            type: .like(post))
                            feeds.append(feed)
                            if(feeds.count == feedDictionaries.count){
                                completion(feeds)
                                return
                            }
                        })
                    })
                default:
                    return
                }
            }
        })
    }
}


