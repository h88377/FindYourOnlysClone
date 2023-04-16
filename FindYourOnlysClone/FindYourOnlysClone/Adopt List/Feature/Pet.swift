//
//  Pet.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import Foundation

struct Pet: Hashable, Decodable {
    let id: Int
    let location: String
    let kind: String
    let gender: String
    let bodyType: String
    let color: String
    let age: String
    let sterilization: String
    let bacterin: String
    let foundPlace: String
    let status: String
    let remark: String
    let openDate: Date
    let closedDate: Date
    let updatedDate: Date
    let createdDate: Date
    let photoURL: URL
    let address: String
    let telephone: String
    let variety: String
    let shelterName: String
}
