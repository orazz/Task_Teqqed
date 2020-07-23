//
//  ClientApi.swift
//  Task_Teqqed
//
//  Created by Oraz Atakishiyev on 7/21/20.
//  Copyright © 2020 orazz. All rights reserved.
//

import Foundation

struct KeyWords {
    static var BASE_URL = "http://jsonplaceholder.typicode.com"
}

let dataErrorDomain = "dataErrorDomain"

enum DataErrorCode: NSInteger {
    case networkUnavailable = 101
    case wrongDataFormat = 102
}

protocol APIDataProviderType {
    func getPosts(forUserId userId: Int?, completion: @escaping([Post]?, Error?) -> Void)
    func getUser(forUserId userId: Int, completion: @escaping(User?, Error?) -> Void)
    func getComments(forPostId postId: Int, completion: @escaping([Comment]?, Error?) -> Void)
}

final class APIDataProvider {
    
    fileprivate var posts: [Post] = [Post]()
    
    private let baseURL = URL(string: KeyWords.BASE_URL)!
    
    private func getList<Model: Decodable>(url: URL, completion: @escaping(Result<[Model], Error>) -> Void) {
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: dataErrorDomain, code: DataErrorCode.networkUnavailable.rawValue, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            if let items = try? JSONDecoder().decode([Model].self, from: data) {
                return completion(.success(items))
            }
            
        }
        task.resume()
    }
}

extension APIDataProvider: APIDataProviderType {
    
    func getPosts(forUserId userId: Int?, completion: @escaping([Post]?, Error?) -> Void) {
        
        if let userId = userId {
            let url = "\(KeyWords.BASE_URL)/posts?userId=\(userId)"
            getList(url: URL(string: url)!) { (_ result: Result<[Post], Error>) in
                switch result {
                case .failure(let error):
                    completion(nil, error)
                case .success(let items):
                    completion(items, nil)
                }
            }
        }
        
        getList(url: baseURL.appendingPathComponent("posts")) { (_ result: Result<[Post], Error>) in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let items):
                completion(items, nil)
            }
        }
    }
    
    func getUser(forUserId userId: Int, completion: @escaping(User?, Error?) -> Void) {
        let url = "\(KeyWords.BASE_URL)/users?id=\(userId)"
        
        getList(url: URL(string: url)!) { (_ result: Result<[User], Error>) in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let items):
                completion(items.first, nil)
            }
        }
    }

    func getComments(forPostId postId: Int, completion: @escaping([Comment]?, Error?) -> Void) {
        let url = "\(KeyWords.BASE_URL)/comments?postId=\(postId)"
        getList(url: URL(string: url)!) { (_ result: Result<[Comment], Error>) in
            switch result {
            case .failure(let error):
                completion(nil, error)
            case .success(let items):
                completion(items, nil)
            }
        }
    }
}
