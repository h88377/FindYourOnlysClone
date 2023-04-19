//
//  RemotePetLoaderTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import XCTest
@testable import FindYourOnlysClone

class RemotePetLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.receivedURLs.isEmpty)
    }
    
    func test_loadWithRequest_requestsDataFromRequest() {
        let request = AdoptListRequest(page: 0)
        let url = URL(string: "https://any-url.com")!
        let expectedURL = makeExpectedURL(url, with: request)
        let (sut, client) = makeSUT(baseURL: url)
        
        sut.load(with: request) { _ in }
        
        XCTAssertEqual(client.receivedURLs, [expectedURL])
    }
    
    func test_loadWithRequestTwice_requestsDataFromRequestTwice() {
        let request = AdoptListRequest(page: 0)
        let url = URL(string: "https://any-url.com")!
        let expectedURL = makeExpectedURL(url, with: request)
        let (sut, client) = makeSUT(baseURL: url)
        
        sut.load(with: request) { _ in }
        sut.load(with: request) { _ in }
        
        XCTAssertEqual(client.receivedURLs, [expectedURL, expectedURL])
    }
    
    func test_loadWithRequest_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.completesWithError()
        })
    }
    
    func test_loadWithRequest_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        
        for (index, statusCode) in samples.enumerated() {
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.completesWith(statusCode: statusCode, at: index)
            })
        }
    }
    
    func test_loadWithRequest_deliversErrorOn200HTTPResponseWithInvalidData() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidData = Data("invalid data".utf8)
            client.completesWith(statusCode: 200, data: invalidData)
        })
    }
    
    func test_loadWithRequest_deliversEmptyResultOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyData = makePetsJSONData([])
            client.completesWith(statusCode: 200, data: emptyData)
        })
    }
    
    func test_loadWithRequest_deliversPetsOn200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        let pet = makePet()
        
        expect(sut, toCompleteWith: .success([pet.model]), when: {
            client.completesWith(statusCode: 200, data: makePetsJSONData([pet.json]))
        })
    }
    
    func test_loadWithRequest_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = anyURL()
        let client = HTTPClientSpy()
        var sut: RemotePetLoader? = RemotePetLoader(baseURL: url, client: client)
        
        var receivedResult: RemotePetLoader.Result?
        sut?.load(with: anyRequest()) { result in
            receivedResult = result
        }
        
        sut = nil
        client.completesWithError()
        
        XCTAssertNil(receivedResult)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(baseURL: URL = URL(string: "https://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (RemotePetLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePetLoader(baseURL: baseURL, client: client)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(client, file: file, line: line)
        return (sut, client)
    }
    
    private func makeExpectedURL(_ url: URL, with request: AdoptListRequest) -> URL {
        let urlString = url.absoluteString
        let expectedURL = URL(string: "\(urlString)?UnitId=QcbUEzN6E6DL&$top=20&$skip=\(20 * request.page)")!
        return expectedURL
    }
    
    private func expect(_ sut: RemotePetLoader, toCompleteWith expectedResult: RemotePetLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        
        sut.load(with: anyRequest()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedPets), .success(expectedPets)):
                XCTAssertEqual(receivedPets, expectedPets, "Expected pets: \(expectedPets), got \(receivedPets) instead", file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as? RemotePetLoader.Error, expectedError as? RemotePetLoader.Error, "Expected error: \(expectedError), got \(receivedError) instead", file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemotePetLoader.Error) -> RemotePetLoader.Result {
        return .failure(error)
    }
    
    private func anyRequest() -> AdoptListRequest {
        return AdoptListRequest(page: 0)
    }
    
    private func makePet(id: Int = 0, location: String = "any location", kind: String = "any kind", gender: String = "M", bodyType: String = "any body", color: String = "any color", age: String = "any age", sterilization: String = "NA", bacterin: String = "NA", foundPlace: String = "any place", status: String = "any status", remark: String = "NA", openDate: String = "2023-04-22", closedDate: String = "2023-04-22", updatedDate: String = "2023-04-22", createdDate: String = "2023-04-22", photoURL: URL = URL(string:"https://any-url.com")!, address: String = "any place", telephone: String = "02", variety: String = "any variety", shelterName: String = "any shelter") -> (model: Pet, json: [String: Any]) {
        
        let pet = Pet(
            id: id,
            location: location,
            kind: kind,
            gender: gender,
            bodyType: bodyType,
            color: color,
            age: age,
            sterilization: sterilization,
            bacterin: bacterin,
            foundPlace: foundPlace,
            status: status,
            remark: remark,
            openDate: openDate,
            closedDate: closedDate,
            updatedDate: updatedDate,
            createdDate: createdDate,
            photoURL: photoURL,
            address: address,
            telephone: telephone,
            variety: variety,
            shelterName: shelterName)
        
        let json: [String : Any] = [
            "animal_id": id,
            "animal_place": location,
            "animal_kind": kind,
            "animal_sex": gender,
            "animal_bodytype": bodyType,
            "animal_colour": color,
            "animal_age": age,
            "animal_sterilization": sterilization,
            "animal_bacterin": bacterin,
            "animal_foundplace": foundPlace,
            "animal_status": status,
            "animal_remark": remark,
            "animal_opendate": openDate,
            "animal_closeddate": closedDate,
            "animal_update": updatedDate,
            "animal_createtime": createdDate,
            "album_file": photoURL.absoluteString,
            "shelter_address": address,
            "shelter_tel": telephone,
            "animal_Variety": variety,
            "shelter_name": shelterName
        ]
        return (pet, json)
    }
    
    private func makePetsJSONData(_ pets: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: pets)
    }
    
    private class HTTPClientSpy: HTTPClient {
        typealias RequestCompletion = (HTTPClient.Result) -> Void
        
        private var receivedMessages = [(request: URLRequest, completion: RequestCompletion)]()
        
        var receivedURLs: [URL] {
            return receivedMessages.map { $0.request.url! }
        }
        
        func dispatch(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            receivedMessages.append((request, completion))
        }
        
        func completesWithError(at index: Int = 0) {
            let error = NSError(domain: "any error", code: 0)
            receivedMessages[index].completion(.failure(error))
        }
        
        func completesWith(statusCode: Int = 200, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: receivedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            receivedMessages[index].completion(.success((data, response)))
        }
    }
}
