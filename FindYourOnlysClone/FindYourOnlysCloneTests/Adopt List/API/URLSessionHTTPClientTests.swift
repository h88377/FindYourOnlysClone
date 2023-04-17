//
//  URLSessionHTTPClientTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_init_doesNotPerformRequestUponCreation() {
        URLProtocolStub.startInterceptingRequest()
        _ = URLSessionHTTPClient()
        
        XCTAssertEqual(URLProtocolStub.receivedURLs, [])
        URLProtocolStub.stopInterceptingRequest()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private(set) static var receivedURLs = [URL]()
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            receivedURLs.append(url)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
    }
}
