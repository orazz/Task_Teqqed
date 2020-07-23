//
//  Post.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation
import CoreData

struct Post: Identifiable, Decodable, Equatable {    
    var id: Int
    var userId: Int
    var title: String
    var body: String
}

struct PostDetails: Decodable {
    var post: Post
    var user: User
    var comments: [Comment]
}
