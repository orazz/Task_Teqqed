//
//  DataProvider.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import CoreData

enum PostDetailsError: Error {
    case receivedInvalidPostDetails
    case userNotFound
}

protocol PostsProvider {
    func getPosts(forUserId userId: Int?, completion: @escaping([Post]?, Error?) -> Void)
}

protocol PostsDetailsProvider {
    func getPostDetails(forPost post: Post, completion: @escaping(PostDetails?, Error?) -> Void)
}

protocol DataProviderType: PostsProvider, PostsDetailsProvider {
}

final class DataProvider {
    
    private var apiDataProvider: APIDataProviderType
    private var databaseDataProvider: DatabaseDataProviderType
    
    init(apiDataProvider: APIDataProviderType, databaseDataProvider: DatabaseDataProviderType) {
        self.apiDataProvider = apiDataProvider
        self.databaseDataProvider = databaseDataProvider
    }
}

extension DataProvider: DataProviderType {
    
    func getPosts(forUserId userId: Int?, completion: @escaping([Post]?, Error?) -> Void) {
        apiDataProvider.getPosts(forUserId: userId, completion: { (posts, error) in
            if let posts = posts {
                self.databaseDataProvider.cachePosts(posts)
                completion(posts, nil)
            } else {
                let posts = self.databaseDataProvider.getPosts(forUserId: nil)
                if posts.isEmpty {
                    completion(nil, error)
                } else {
                    completion(posts, nil)
                }
            }
        })
    }
    
    func getPostDetails(forPost post: Post, completion: @escaping(PostDetails?, Error?) -> Void) {
        
        var user: User? = nil
        var comments: [Comment]? = []
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        apiDataProvider.getUser(forUserId: post.userId) { (item, error) in
            if error != nil {
                completion(nil, error)
            } else if let _user = item {
                self.databaseDataProvider.cacheUser(_user)
                user = _user
            } else {
                let _user = self.databaseDataProvider.getUser(forUserId: post.userId)
                
                if _user != nil {
                    user = _user
                } else {
                    completion(nil, PostDetailsError.userNotFound)
                }
            }
            group.leave()
        }
        
        apiDataProvider.getComments(forPostId: post.id) { (res, error) in
            if error != nil {
                completion(nil, error)
            } else if let com = res {
                self.databaseDataProvider.cacheComments(com)
                comments = com
            } else {
                let comms = self.databaseDataProvider.getComments(forPostId: post.id)
                comments = comms
            }
            group.leave()
        }
        
        
        group.notify(queue: DispatchQueue.main, execute: {
            completion(PostDetails(post: post, user: user!, comments: comments!), nil)
        })
    }
}


