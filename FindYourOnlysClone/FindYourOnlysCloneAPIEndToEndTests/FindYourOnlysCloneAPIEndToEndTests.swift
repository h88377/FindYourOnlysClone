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
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
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
    
    func test_endToEndTestServerGetPetImageDataReuslt_matchesFixedPetImageData() {
        let url = URL(string: "https://www.pet.gov.tw/upload/pic/1681889366849.png")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let sut = RemotePetImageDataLoader(client: client)
        let exp = expectation(description: "Wait for result")

        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(data):
                XCTAssertFalse(data.isEmpty, "Expected data is not empty")

            default:
                XCTFail("Expected to succeed with non-empty data, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 20.0)
    }
    
    // MARK: - Helpers
    
    func getPetsResult() {
        let url = URL(string: "https://data.coa.gov.tw/Service/OpenData/TransService.aspx")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let sut = RemotePetLoader(baseURL: url, client: client)
        trackfor
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
