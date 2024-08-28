//
//  NetworkManager.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import UIKit

class NetworkManager {
    
    enum HTTPMethod: String {
        case GET
    }
    
    enum Headers: String {
        case ContentLengh = "Content-Lengdh"
        case ContentType = "Content-Type"
        case Path = "application/json"
        case Authorization = "Authorization"
    }
    
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue(Headers.Path.rawValue, forHTTPHeaderField: Headers.ContentType.rawValue)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else { return }
                completion(.success(data))
            }
        }.resume()
    }
    
    func getTodos(complitionHandler: @escaping ([Todos]) -> Void) {
        if let url = URL(string: "https://dummyjson.com/todos") {
            request(url: url) { (result) in
                switch result {
                case .success(let data):
                    do {
                        let todos = try JSONDecoder().decode(JsonTodos.self, from: data)
                        complitionHandler(todos.todos)
                    } catch let jsonError {
                        print("Failed to decode JSON", jsonError)
                        complitionHandler([])
                    }
                case .failure(let error):
                    print("Error received requesting data: \(error.localizedDescription)")
                    complitionHandler([])
                }
            }
        }
    }
}
