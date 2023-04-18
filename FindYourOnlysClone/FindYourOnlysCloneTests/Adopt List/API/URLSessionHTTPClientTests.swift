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
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError! as NSError).domain, requestError.domain)
        XCTAssertEqual((receivedError! as NSError).code, requestError.code)
    }
    
    func test_dispatchRequest_failsOnInvalidCompletionCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil))
    }
    
    func test_dispatchRequest_succeedsOnEmptyDataWithHTTPURLResponseWithNilError() {
        let emptyData = Data()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: emptyData, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_dispatchRequest_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
        let request = anyURLRequest()
        let exp = expectation(description: "Wait for completion")
         
        URLProtocolStub.stub(data: data, response: response, error: error)
        var receivedResult: HTTPClient.Result?
        makeSUT(file: file, line: line).dispatch(request) { result in
            receivedResult = result
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        var receivedValues: (data: Data, response: HTTPURLResponse)?
        
        switch result {
        case let .success((data, response)):
            receivedValues = (data, response)
            
        default:
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
        }
        
        return receivedValues
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        var receivedError: Error?
        
        switch result {
        case let .failure(error):
            receivedError = error
            
        default:
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func anyURLRequest(from url: URL = URL(string: "https://any-url.com")!) -> URLRequest {
        return URLRequest(url: url)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyData() -> Data {
        return Data("anyData".utf8)
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
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
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
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
