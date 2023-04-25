//
//  SharedTestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/19.
//

import XCTest

extension XCTestCase {
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func anyData() -> Data {
        return Data("anyData".utf8)
    }
}
