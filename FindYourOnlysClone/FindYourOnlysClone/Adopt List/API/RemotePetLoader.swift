//
//  RemotePetLoader.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import Foundation

final class RemotePetLoader {
    typealias Result = Swift.Result<[Pet], Error>
    
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
        client.dispatch(URLRequest(url: url)) { result in
            switch result {
            case let .success((data, response)):
                guard response.statusCode == 200, let pets = try? JSONDecoder().decode([Pet].self, from: data) else {
                    return completion(.failure(.invalidData))
                }
                
                completion(.success(pets))
                
            case .failure:
                completion(.failure(.connectivity))
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
}
