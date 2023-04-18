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
        
        var receivedRequest: URLRequest?
        URLProtocolStub.observeRequest { request in
            receivedRequest = request
        }
        
        XCTAssertNil(receivedRequest)
    }
    
    func test_dispatchRequest_performsGetRequest() {
        let sut = makeSUT()
        let url = anyURL()
        let request = URLRequest(url: url)
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.dispatch(request) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_dispatchRequest_failsOnRequestError() {
        let request = URLRequest(url: URL(string: "https://any-url.com")!)
        let error = NSError(domain: "any error", code: 0)
        let sut = makeSUT()
        let exp = expectation(description: "Wait for completion")
         
        URLProtocolStub.stub(url: request.url!, data: nil, response: nil, error: error)
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
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        private static var requestObserverHandler: ((URLRequest) -> Void)?
        
        private static var stub: Stub?

        static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
            requestObserverHandler = observer
        }
        
        static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            stub = nil
            requestObserverHandler = nil
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserverHandler?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
}
