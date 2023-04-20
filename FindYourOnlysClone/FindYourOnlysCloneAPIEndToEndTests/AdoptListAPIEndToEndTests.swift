//
//  FindYourOnlysCloneAPIEndToEndTests.swift
//  FindYourOnlysCloneAPIEndToEndTests
//
//  Created by 鄭昭韋 on 2023/4/18.
//

import XCTest
@testable import FindYourOnlysClone

final class AdoptListAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGetPetsReuslt_matchesFixedPetsCount() {
        switch getPetsResult() {
        case let .success(pets):
            XCTAssertEqual(pets.count, 20)
            
        case let .failure(error):
            XCTFail("Expected to succeed with 20 pets data, got \(error)) instead")
            
        default:
            XCTFail("Expected to succeed with 20 pets data, got no result instead")
        }
    }
    
    // MARK: - Helpers
    
    func getPetsResult(file: StaticString = #filePath, line: UInt = #line) -> PetLoader.Result? {
        let url = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx")!
        let client = makeEphemeralClient()
        let sut = RemotePetLoader(baseURL: url, client: client)
        let exp = expectation(description: "Wait for result")
        
        trackForMemoryLeak(sut, file: file, line: line)
        
        var receivedResult: PetLoader.Result?
        sut.load(with: AdoptListRequest(page: 0)) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func makeEphemeralClient(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeak(client, file: file, line: line)
        return client
    }
}
