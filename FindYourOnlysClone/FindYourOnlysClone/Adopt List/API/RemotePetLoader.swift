//
//  RemotePetLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import Foundation

final class RemotePetLoader: PetLoader {
    typealias Result = PetLoader.Result
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let baseURL: URL
    private let client: HTTPClient
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func load(with request: AdoptListRequest, completion: @escaping (Result) -> Void) {
        let url = enrich(baseURL, with: request)
        client.dispatch(URLRequest(url: url)) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemotePetLoader.map(with: data, response))
                
            case .failure:
                completion(.failure(RemotePetLoader.Error.connectivity))
            }
        }
    }
    
    private func enrich(_ baseURL: URL, with request: AdoptListRequest) -> URL {
        var component = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        component?.queryItems = [
            URLQueryItem(name: "UnitId", value: "QcbUEzN6E6DL"),
            URLQueryItem(name: "$top", value: "20"),
            URLQueryItem(name: "$skip", value: "\(20 * request.page)"),
        ]
        
        return component?.url ?? baseURL
    }
    
    private static func map(with data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let remotePets = try PetsMapper.map(with: data, response)
            return .success(remotePets.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemotePet {
    func toModels() -> [Pet] {
        return map { Pet(id: $0.id, location: $0.location, kind: $0.kind, gender: $0.gender, bodyType: $0.bodyType, color: $0.color, age: $0.age, sterilization: $0.sterilization, bacterin: $0.bacterin, foundPlace: $0.foundPlace, status: $0.status, remark: $0.remark, openDate: $0.openDate, closedDate: $0.closedDate, updatedDate: $0.updatedDate, createdDate: $0.createdDate, photoURL: URL(string: $0.photoURLString), address: $0.address, telephone: $0.telephone, variety: $0.variety, shelterName: $0.shelterName) }
    }
}
