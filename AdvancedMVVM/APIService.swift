//
//  APIService.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 27/5/23.
//

import Foundation
import Alamofire

protocol APIServiceProtocol {
    associatedtype ResponseData
    func fetchAllTodos(completion: (ResponseData) -> (Void)) -> (Void)
}

class APIService: APIServiceProtocol {
    static let shared = APIService()
    
    private init() {}
    
    typealias ResponseData = Data
    
    func fetchAllTodos(completion: @escaping (Data) -> (Void)) {
        let url = URL(string: "http://localhost:8080/api/todos")!
        AF.request(url).responseJSON { response in
            debugPrint(response.data)
            completion(response.data!)
        }
    }
}
