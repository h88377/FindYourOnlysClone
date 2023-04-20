//
//  URLProtocolStub.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import Foundation

class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserverHandler: ((URLRequest) -> Void)?
    }
    
    private static var _stub: Stub?
    private static var stub: Stub? {
        get { queue.sync { return _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserverHandler: observer)
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserverHandler: nil)
    }
    
    static func startInterceptingRequest() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequest() {
        stub = nil
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
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
        URLProtocolStub.stub?.requestObserverHandler?(request)
    }
    
    override func stopLoading() {}
}
