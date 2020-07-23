//
//  PostDetailsTableView.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/23/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import UIKit

class PostDetailsAuthorCell: UITableViewCell {
    static let identifier = "PostDetailsAuthorCell"
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var name: UILabel!
    
    func config(post: PostDetails) {
        username.text = post.user.username
        name.text = post.user.email
    }
}


class PostDetailsContentCell: UITableViewCell {
    static let identifier = "PostDetailsContentCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!

    func config(post: PostDetails) {
        title.text = post.post.title
        body.text = post.post.body
    }
}

class PostDetailsCommentCell: UITableViewCell {
    static let identifier = "PostDetailsCommentCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!

    func config(comment: Comment) {
        title.text = comment.name
        body.text = comment.body
    }
}
