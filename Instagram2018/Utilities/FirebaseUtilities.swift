//
//  FirebaseUtilities.swift
//  Instagram2018
//
//  Created by wry on 2018/10/5.
//  Copyright © 2018年 jiacheng. All rights reserved.
//  Include all functions that interact with the database
//  Function list:
//  For Authentication: createUser, uploadUser
//  For Storage: uploadUserProfileImage, uploadPostImage
//  For Database:
//      User Table: fetchUser, fetchAllUsers, fetchSuggestedUsers,fetchSameSexUsers
//      Following & Followers: isFollowingUser, followUser, unfollowUser
//      Post Table: createPost, fetchPost, fetchAllPosts, deletePost
//      Comment Table: addCommentToPost, fetchCommentsForPost
//      Like: userOfLikesForPost (returns a list of users who liked a specific post)
//      Utilities: numberOfPostsForUser, numberOfFollowersForUser,
//                 numberOfFollowingForUser, numberOfLikesForPost

import Foundation
import Firebase

extension Auth {
    func createUser(withEmail email: String, username: String,
                    password: String, image: UIImage?, sex: String?,
                    completion: @escaping (Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password,
                               completion: { (user, err) in
                                if let err = err {
                                    print("Failed to create user:", err)
                                    completion(err)
                                    return
                                }
                                guard let uid = user?.user.uid else { return }
                                if let image = image {
                                    Storage.storage().uploadUserProfileImage(
                                        image: image, completion: { (profileImageUrl) in
                                            self.uploadUser(withUID: uid, username: username,
                                                            profileImageUrl: profileImageUrl, sex: sex) {
                                                                completion(nil)
                                            }
                                    })
                                } else {
                                    self.uploadUser(withUID: uid, username: username, sex: sex) {
                                        completion(nil)
                                    }
                                }
        })
    }
    
    private func uploadUser(withUID uid: String, username: String,
                            profileImageUrl: String? = nil, sex: String?,
                            completion: @escaping (() -> ())) {
        var dictionaryValues = ["username": username]
        if profileImageUrl != nil {
            dictionaryValues["profileImageUrl"] = profileImageUrl
        }
        
        dictionaryValues["sex"] = sex
        
        let values = [uid: dictionaryValues]
        Database.database().reference().child("users")
            .updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print("Failed to upload user to database:", err)
                    return
                }
                completion()
            })
    }
}

extension Storage {
    
    fileprivate func uploadUserProfileImage(
        image: UIImage, completion: @escaping (String) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return }
        
        let storageRef = Storage.storage().reference()
            .child("profile_images").child(NSUUID().uuidString)
        
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload profile image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to obtain download url for profile image:", err)
                    return
                }
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(profileImageUrl)
            })
        })
    }
    
    fileprivate func uploadPostImage(
        image: UIImage, filename: String, completion: @escaping (String) -> ()) {
        guard let uploadData = image.jpegData(compressionQuality: 1) else { return }
        
        let storageRef = Storage.storage().reference()
            .child("post_images").child(filename)
        storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let err = err {
                print("Failed to upload post image:", err)
                return
            }
            
            storageRef.downloadURL(completion: { (downloadURL, err) in
                if let err = err {
                    print("Failed to obtain download url for post image:", err)
                    return
                }
                guard let postImageUrl = downloadURL?.absoluteString else { return }
                completion(postImageUrl)
            })
        })
    }
}

extension Database {
    
    //MARK: Users
    
    func fetchUser(withUID uid: String, completion: @escaping (User) -> ()) {
        Database.database().reference()
            .child("users").child(uid).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userDictionary)
                completion(user)
            }) { (err) in
                print("Failed to fetch user from database:", err)
        }
    }
    
    func fetchAllUsers(includeCurrentUser: Bool = true,
                       completion: @escaping ([User]) -> (),
                       withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var users = [User]()
            
            dictionaries.forEach({ (key, value) in
                if !includeCurrentUser, key == Auth.auth().currentUser?.uid {
                    completion([])
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                users.append(user)
            })
            
            users.sort(by: { (user1, user2) -> Bool in
                return user1.username.compare(user2.username) == .orderedAscending
            })
            completion(users)
            
        }) { (err) in
            print("Failed to fetch all users from database:", (err))
            cancel?(err)
        }
    }
    
    //given current user, return users who are followed by the users
    //that current user is following, not include users who are already followed
    //by the current user
    func fetchSuggestedUsers(
        currentUser: User?,
        completion: @escaping ([User]) -> (), withCancel cancel: ((Error) -> ())?) {
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("following").child(currentUserId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var followingUserfollowingUsers = [User]()
            
            var uniqueFollowingUserfollowingUsers = [User]()
            
            var keys = [String]()
            
            dictionaries.forEach({ (key, value) in
                
                Database.database().fetchFollowingUsers(
                    withId: key, completion: { (followingUsers) in
                        
                        keys.append(key)
                        guard let currentUser = currentUser else { return }
                        followingUserfollowingUsers += followingUsers
                        if followingUserfollowingUsers.count <= 0 {
                            uniqueFollowingUserfollowingUsers = []
                        }
                            
                        else{
                            for followingUserfollowingUser in followingUserfollowingUsers {
                                //remove duplicated following users,
                                //remove current user self
                                if !uniqueFollowingUserfollowingUsers
                                    .contains(followingUserfollowingUser),
                                    followingUserfollowingUser.uid != currentUser.uid
                                {
                                    uniqueFollowingUserfollowingUsers
                                        .append(followingUserfollowingUser)
                                }
                                //also remove users who have been followed by the current user
                                if keys.contains(followingUserfollowingUser.uid){
                                    if let index =
                                        uniqueFollowingUserfollowingUsers
                                            .index(of: followingUserfollowingUser) {
                                        uniqueFollowingUserfollowingUsers.remove(at: index)
                                    }
                                }
                            }
                            
                            uniqueFollowingUserfollowingUsers
                                .sort(by: { (user1, user2) -> Bool in
                                return user1.username.compare(
                                    user2.username) == .orderedAscending
                            })
                            
                        }
                        completion(uniqueFollowingUserfollowingUsers)
                })
                
            })
            
        }) { (err) in
            print("Failed to fetch suggested users from database:", (err))
            cancel?(err)
        }
        
    }
    
    //given current user, return users who have the same sex as the current user
    func fetchSameSexUsers(
        currentUser: User?, includeCurrentUser: Bool = true,
        completion: @escaping ([User]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var users = [User]()
            
            dictionaries.forEach({ (key, value) in
                if !includeCurrentUser, key == Auth.auth().currentUser?.uid {
                    completion([])
                    return
                }
                guard let userDictionary = value as? [String: Any] else { return }
                let user = User(uid: key, dictionary: userDictionary)
                guard let currentUser = currentUser else { return }
                
                Database.database().fetchFollowingUsers(
                    withId: currentUser.uid, completion: { (followingUsers) in
                        
                        //remove duplicates,
                        //remove users who have been followed by the current user
                        //choose the user with the same sex as current user
                        if !users.contains(user),
                            user.sex == currentUser.sex,
                            !followingUsers.contains(user){
                            users.append(user)
                        }
                        users.sort(by: { (user1, user2) -> Bool in
                            return user1.username.compare(
                                user2.username) == .orderedAscending
                        })
                        completion(users)
                        
                })
            })
            
        }) { (err) in
            print("Failed to fetch same sex users from database:", (err))
            cancel?(err)
        }
    }
    
    func isFollowingUser(
        withUID uid: String, completion: @escaping (Bool) -> (),
        withCancel cancel: ((Error) -> ())?) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference()
            .child("following").child(currentLoggedInUserId)
            .child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }) { (err) in
                print("Failed to check if following:", err)
                cancel?(err)
        }
    }
    
    func followUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        let values = [uid: 1]
        Database.database().reference()
            .child("following").child(currentLoggedInUserId)
            .updateChildValues(values) { (err, ref) in
                if let err = err {
                    completion(err)
                    return
                }
                
                let values = [currentLoggedInUserId: 1]
                Database.database().reference()
                    .child("followers").child(uid).updateChildValues(values) {
                        (err, ref) in
                        if let err = err {
                            completion(err)
                            return
                        }
                        // Record follow feeds
                        let feedRef = Database.database().reference()
                            .child("feed").child(uid).childByAutoId()
                        let feedValue = ["type": Feed.followType,
                                         "user": currentLoggedInUserId,
                                         "creationDate": Date().timeIntervalSince1970] as
                                            [String : Any]
                        feedRef.updateChildValues(feedValue)
                        completion(nil)
                }
        }
    }
    
    func unfollowUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference()
            .child("following").child(currentLoggedInUserId)
            .child(uid).removeValue { (err, _) in
                if let err = err {
                    print("Failed to remove user from following:", err)
                    completion(err)
                    return
                }
                
                Database.database().reference()
                    .child("followers").child(uid).child(currentLoggedInUserId)
                    .removeValue(completionBlock: { (err, _) in
                        if let err = err {
                            print("Failed to remove user from followers:", err)
                            completion(err)
                            return
                        }
                        completion(nil)
                    })
        }
    }
    
    //MARK: Posts
    
    func createPost(
        withImage image: UIImage, caption: String, address: String,
        location: [Double], completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userPostRef = Database.database().reference()
            .child("posts").child(uid).childByAutoId()
        
        guard let postId = userPostRef.key else { return }
        
        Storage.storage().uploadPostImage(image: image, filename: postId) {
            (postImageUrl) in
            let values = ["imageUrl": postImageUrl, "caption": caption,
                          "address": address,"location": location,
                          "imageWidth": image.size.width,
                          "imageHeight": image.size.height,
                          "creationDate": Date().timeIntervalSince1970,
                          "id": postId] as [String : Any]
            
            userPostRef.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("Failed to save post to database", err)
                    completion(err)
                    return
                }
                completion(nil)
            }
        }
    }
    
    func fetchPost(
        withUID uid: String, postId: String,
        completion: @escaping (Post) -> (), withCancel cancel: ((Error) -> ())? = nil) {
        guard let currentLoggedInUser = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
            .child("posts").child(uid).child(postId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let postDictionary = snapshot.value as? [String: Any] else { return }
            
            Database.database().fetchUser(withUID: uid, completion: { (user) in
                var post = Post(user: user, dictionary: postDictionary)
                post.id = postId
                
                //check likes
                Database.database().reference()
                    .child("likes").child(postId).child(currentLoggedInUser)
                    .observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? Int, value == 1 {
                            post.likedByCurrentUser = true
                        } else {
                            post.likedByCurrentUser = false
                        }
                        
                        Database.database().numberOfLikesForPost(
                            withPostId: postId, completion: { (count) in
                                post.likes = count
                                completion(post)
                        })
                    }, withCancel: { (err) in
                        print("Failed to fetch like info for post:", err)
                        cancel?(err)
                    })
            })
        })
    }
    
    func fetchAllPosts(
        withUID uid: String,
        completion: @escaping ([Post]) -> (), withCancel cancel: ((Error) -> ())?) {
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var posts = [Post]()
            
            dictionaries.forEach({ (postId, value) in
                Database.database().fetchPost(withUID: uid, postId: postId,
                                              completion: { (post) in
                                                posts.append(post)
                                                
                                                if posts.count == dictionaries.count {
                                                    completion(posts)
                                                }
                })
            })
        }) { (err) in
            print("Failed to fetch posts:", err)
            cancel?(err)
        }
    }
    
    func deletePost(withUID uid: String, postId: String,
                    completion: ((Error?) -> ())? = nil) {
        Database.database().reference()
            .child("posts").child(uid).child(postId).removeValue { (err, _) in
                if let err = err {
                    print("Failed to delete post:", err)
                    completion?(err)
                    return
                }
                
                Database.database().reference()
                    .child("comments").child(postId).removeValue(completionBlock: {
                        (err, _) in
                        if let err = err {
                            print("Failed to delete comments on post:", err)
                            completion?(err)
                            return
                        }
                        
                        Database.database().reference().child("likes")
                            .child(postId).removeValue(completionBlock: { (err, _) in
                                if let err = err {
                                    print("Failed to delete likes on post:", err)
                                    completion?(err)
                                    return
                                }
                                
                                Storage.storage().reference().child("post_images")
                                    .child(postId).delete(completion: { (err) in
                                        if let err = err {
                                            print("Failed to delete post image from storage:", err)
                                            completion?(err)
                                            return
                                        }
                                    })
                                
                                completion?(nil)
                            })
                    })
        }
    }
    
    func addCommentToPost(withId postId: String, text: String,
                          completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["text": text, "creationDate": Date().timeIntervalSince1970,
                      "uid": uid] as [String: Any]
        
        let commentsRef = Database.database().reference().child("comments")
            .child(postId).childByAutoId()
        commentsRef.updateChildValues(values) { (err, _) in
            if let err = err {
                print("Failed to add comment:", err)
                completion(err)
                return
            }
            completion(nil)
        }
    }
    
    func fetchCommentsForPost(
        withId postId: String,
        completion: @escaping ([Comment]) -> (), withCancel cancel: ((Error) -> ())?) {
        let commentsReference = Database.database().reference()
            .child("comments").child(postId)
        
        commentsReference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var comments = [Comment]()
            
            dictionaries.forEach({ (key, value) in
                guard let commentDictionary = value as? [String: Any] else { return }
                guard let uid = commentDictionary["uid"] as? String else { return }
                
                Database.database().fetchUser(withUID: uid) { (user) in
                    let comment = Comment(user: user, dictionary: commentDictionary)
                    comments.append(comment)
                    
                    if comments.count == dictionaries.count {
                        comments.sort(by: { (comment1, comment2) -> Bool in
                            return comment1.creationDate.compare(comment2.creationDate)
                                == .orderedAscending
                        })
                        completion(comments)
                    }
                }
            })
            
        }) { (err) in
            print("Failed to fetch comments:", err)
            cancel?(err)
        }
    }
    
    func userOfLikesForPost(
        withId postId: String, completion: @escaping ([User]) -> (),
        withCancel cancel: ((Error) -> ())?) {
        let likesReference = Database.database().reference().child("likes").child(postId)
        
        likesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var likedUsers = [User]()
            
            dictionaries.forEach({ (key, value) in
                Database.database().fetchUser(withUID: key) { (likedUser) in
                    likedUsers.append(likedUser)
                    
                    if likedUsers.count == dictionaries.count {
                        likedUsers.sort(by: { (likedUser1, likedUser2) -> Bool in
                            return likedUser1.username.compare(likedUser2.username)
                                == .orderedAscending
                        })
                        completion(likedUsers)
                    }
                }
                
            })
            
        }) { (err) in
            print("Failed to fetch liked users:", err)
            cancel?(err)
        }
    }
    
    func fetchFollowingUsers(
        withId userID: String, completion: @escaping ([User]) -> ()) {
        let followingReference = Database.database().reference().child("following").child(userID)
        
        followingReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else {
                completion([])
                return
            }
            
            var followingUsers = [User]()
            
            dictionaries.forEach({ (key, value) in
                Database.database().fetchUser(withUID: key) { (followingUser) in
                    followingUsers.append(followingUser)
                    
                    if followingUsers.count == dictionaries.count {
                        followingUsers.sort(by: { (followingUser1, followingUser2) -> Bool in
                            return followingUser1.username.compare(followingUser2.username)
                                == .orderedAscending
                        })
                        completion(followingUsers)
                    }
                }
                
            })
            
            
        }) { (err) in
            print("Failed to fetch following users:", err)
        }
    }
    
    //MARK: Utilities
    
    func numberOfPostsForUser(withUID uid: String,
                              completion: @escaping (Int) -> ()) {
        Database.database().reference().child("posts")
            .child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionaries = snapshot.value as? [String: Any] {
                    completion(dictionaries.count)
                } else {
                    completion(0)
                }
        }
    }
    
    func numberOfFollowersForUser(withUID uid: String,
                                  completion: @escaping (Int) -> ()) {
        Database.database().reference().child("followers")
            .child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionaries = snapshot.value as? [String: Any] {
                    completion(dictionaries.count)
                } else {
                    completion(0)
                }
        }
    }
    
    func numberOfFollowingForUser(withUID uid: String,
                                  completion: @escaping (Int) -> ()) {
        Database.database().reference().child("following")
            .child(uid).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionaries = snapshot.value as? [String: Any] {
                    completion(dictionaries.count)
                } else {
                    completion(0)
                }
        }
    }
    
    func numberOfLikesForPost(withPostId postId: String,
                              completion: @escaping (Int) -> ()) {
        Database.database().reference().child("likes")
            .child(postId).observeSingleEvent(of: .value) { (snapshot) in
                if let dictionaries = snapshot.value as? [String: Any] {
                    completion(dictionaries.count)
                } else {
                    completion(0)
                }
        }
    }
}
