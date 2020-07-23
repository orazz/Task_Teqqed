//
//  ViewController.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let apiDataProvider = APIDataProvider()
    let databaseDataProvider = DatabaseDataProvider()
    var viewModel: PostsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataProvider = DataProvider(
        apiDataProvider: apiDataProvider,
        databaseDataProvider: databaseDataProvider)
        viewModel = PostsViewModel(postsProvider: dataProvider)
        bindViewModel()
        viewModel.fetchPosts()
        
        self.tableView.tableFooterView = UIView()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell {
            let i = tableView.indexPath(for: cell)!.row
            if segue.identifier == "PostDetailsVC" {
                let vc = segue.destination as! PostDetailsVC
                vc.post = self.viewModel.posts[i]
            }
        }
    }

}

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        cell.config(item: self.viewModel.posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

