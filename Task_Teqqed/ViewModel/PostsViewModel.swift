//
//  PostsViewModel.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/22/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation

final class PostsViewModel {
    
    private let postsProvider: PostsProvider
    var didStartLoading: () -> Void = { }
    var didFinishLoading: () -> Void = { }
    var didFinishWithError: (Error) -> Void = { _ in }
    var posts: [Post] = [Post]()
    
    init(postsProvider: PostsProvider) {
        self.postsProvider = postsProvider
    }
    
    func fetchPosts() {
        self.didStartLoading()
        self.postsProvider.getPosts(forUserId: nil) { (posts, error) in
            if let error = error {
                self.didFinishWithError(error)
            } else {
                self.posts = posts!
            }
            self.didFinishLoading()
        }
    }
}
