//
//  PostDetailsViewModel.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/23/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation

final class PostDetailsViewModel {
    
    private let postsProvider: PostsDetailsProvider
    var didStartLoading: () -> Void = { }
    var didFinishLoading: () -> Void = { }
    var didFinishWithError: (Error) -> Void = { _ in }
    var postDetails: PostDetails!
    
    init(postsProvider: PostsDetailsProvider) {
        self.postsProvider = postsProvider
    }
    
    func fetchPostDetails(post: Post) {
        self.didStartLoading()
        self.postsProvider.getPostDetails(forPost: post, completion: { (postDetails, error) in
          if let error = error {
                self.didFinishWithError(error)
            } else {
                self.postDetails = postDetails!
            }
            self.didFinishLoading()
        })
    }
    
    func rowCount() -> Int {
        if postDetails != nil {
            return postDetails.comments.count + 2
        } else {
            return 0
        }
    }
}
