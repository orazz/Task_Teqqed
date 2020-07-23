//
//  PostdetailsVC.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/23/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import UIKit

class PostDetailsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let apiDataProvider = APIDataProvider()
    let databaseDataProvider = DatabaseDataProvider()
    var viewModel: PostDetailsViewModel!
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataProvider = DataProvider(
        apiDataProvider: apiDataProvider,
        databaseDataProvider: databaseDataProvider)
        viewModel = PostDetailsViewModel(postsProvider: dataProvider)
        bindViewModel()
        viewModel.fetchPostDetails(post: post)
        tableView.tableFooterView = UIView()
    }

    func bindViewModel() {
        viewModel.didStartLoading = {
            self.startIndicatingActivity()
        }
        
        viewModel.didFinishWithError = { error in
            DispatchQueue.main.async {
                self.presentAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }
        
        viewModel.didFinishLoading = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.stopIndicatingActivity()
        }
    }
}

extension PostDetailsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let postDetails = self.viewModel.postDetails else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailsAuthorCell.identifier, for: indexPath) as! PostDetailsAuthorCell
            cell.config(post: postDetails)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailsContentCell.identifier, for: indexPath) as! PostDetailsContentCell
            cell.config(post: postDetails)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: PostDetailsCommentCell.identifier, for: indexPath) as! PostDetailsCommentCell
            cell.config(comment: postDetails.comments[indexPath.row-2])
            return cell
        }
    }
}
