//
//  URLSessionHTTPClient.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/18.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    typealias Result = HTTPClient.Result
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedCompletionError: Error {}
    
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedCompletionError()))
            }
            
        }.resume()
    }
}
