//
//  MainTableViewCell.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/23/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    static let identifier = "MainTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(item: Post) {
        self.titleLabel.text = item.title
        self.bodyLabel.text = item.body
    }
}
