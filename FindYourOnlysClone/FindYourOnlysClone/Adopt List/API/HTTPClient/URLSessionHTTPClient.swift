//
//  URLSessionHTTPClient.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/18.
//

import Foundation

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct URLSessionHTTPClientTask: HTTPClientTask {
        private let task: URLSessionTask
        
        init(wrapped task: URLSessionTask) {
            self.task = task
        }
        
        func cancel() {
            task.cancel()
        }
    }
    
    private struct UnexpectedCompletionError: Error {}
    
    func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        let task = session.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedCompletionError()))
            }
        }
        task.resume()
        
        return URLSessionHTTPClientTask(wrapped: task)
    }
}
