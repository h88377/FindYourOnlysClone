//
//  HTTPClientSpy.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import Foundation
@testable import FindYourOnlysClone

class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let cancelCallback: () -> Void
        
        func cancel() {
            cancelCallback()
        }
    }
    
    typealias ReceivedCompletion = (HTTPClient.Result) -> Void
    
    private var receivedMessages = [(url: URL, completion: ReceivedCompletion)]()
    
    var receivedURLs: [URL] {
        return receivedMessages.map { $0.url }
    }
    
    private(set) var cancelledURLs = [URL]()
    
    func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        receivedMessages.append((request.url!, completion))
        return Task { [weak self] in self?.cancelledURLs.append(request.url!) }
    }
    
    func completesWith(error: Error, at index: Int = 0) {
        receivedMessages[index].completion(.failure(error))
    }
    
    func completesWith(statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: receivedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
        receivedMessages[index].completion(.success((data, response)))
    }
}
