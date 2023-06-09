//
//  URLSessionHTTPClientTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequest()
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
    
    func test_cancelDispatchRequestTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for stub to receive request")
        URLProtocolStub.observeRequest { _ in exp.fulfill() }
        
        let cancelledError = resultErrorFor { task in task.cancel() } as NSError?
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(cancelledError?.code, URLError.cancelled.rawValue)
    }
    
    func test_dispatchRequest_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))

        XCTAssertEqual((receivedError! as NSError).domain, requestError.domain)
        XCTAssertEqual((receivedError! as NSError).code, requestError.code)
    }

    func test_dispatchRequest_failsOnInvalidCompletionCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyURLResponse(), error: nil)))
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor((data, response, error), file: file, line: line)
        var receivedValues: (data: Data, response: HTTPURLResponse)?
        
        switch result {
        case let .success((data, response)):
            receivedValues = (data, response)
            
        default:
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
        }
        
        return receivedValues
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        var receivedError: Error?
        
        switch result {
        case let .failure(error):
            receivedError = error
            
        default:
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
        }
        
        return receivedError
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result? {
        values.map {
            URLProtocolStub.stub(data: $0, response: $1, error: $2)
        }
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result?
        taskHandler(sut.dispatch(anyURLRequest()) { result in
            receivedResult = result
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURLRequest(from url: URL = URL(string: "https://any-url.com")!) -> URLRequest {
        return URLRequest(url: url)
    }
    
    private func anyURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)!
    }
}
