//
//  Comment.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation

struct Comment: Decodable, Identifiable {
    var postId: Int
    var id: Int
    var name: String
    var email: String
    var body: String
}
