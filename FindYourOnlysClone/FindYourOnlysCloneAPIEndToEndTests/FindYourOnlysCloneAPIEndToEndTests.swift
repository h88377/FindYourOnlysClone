//
//  FindYourOnlysCloneAPIEndToEndTests.swift
//  FindYourOnlysCloneAPIEndToEndTests
//
//  Created by 鄭昭韋 on 2023/4/18.
//

import XCTest
@testable import FindYourOnlysClone

final class FindYourOnlysCloneAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGetPetsReuslt_matchesFixedPetsCount() {
        let url = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx")!
        let client = URLSessionHTTPClient()
        let sut = RemotePetLoader(baseURL: url, client: client)
        let exp = expectation(description: "Wait for result")
        
        sut.load(with: AdoptListRequest(page: 0)) { result in
            switch result {
            case let .success(pets):
                XCTAssertEqual(pets.count, 20)
                
            default:
                XCTFail("Expected to succeed with 20 pets data, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
}
