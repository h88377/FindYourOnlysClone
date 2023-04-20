//
//  HTTPClient.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import Foundation

protocol HTTPClientTask {
    func cancel()
}

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
