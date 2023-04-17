//
//  URLSessionHTTPClientTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

final class URLSessionHTTPClient {
    typealias Result = HTTPClient.Result
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) {
        session.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_init_doesNotPerformRequestUponCreation() {
        _ = makeSUT()
        
        XCTAssertEqual(URLProtocolStub.receivedURLs, [])
    }
    
    func test_dispatchRequest_failsOnRequestError() {
        let request = URLRequest(url: URL(string: "https://any-url.com")!)
        let error = NSError(domain: "any error", code: 0)
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.stub(url: request.url!, error: error)
        var receivedError: Error?
        sut.dispatch(request) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            
            default:
                XCTFail("Expected \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual((receivedError! as NSError).domain, error.domain)
        XCTAssertEqual((receivedError! as NSError).code, error.code)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        private(set) static var receivedURLs = [URL]()
        
        private static var stubs = [URL: Error]()

        static func stub(url: URL, error: Error) {
            stubs[url] = error
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            receivedURLs = []
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
        
        override func startLoading() {
            if let url = request.url, let error = URLProtocolStub.stubs[url] {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
