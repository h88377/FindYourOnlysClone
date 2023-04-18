//
//  RemotePet.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/17.
//

import Foundation

struct RemotePet: Decodable {
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
    
    enum CodingKeys: String, CodingKey {
        case id = "animal_id"
        case location = "animal_place"
        case kind = "animal_kind"
        case gender = "animal_sex"
        case bodyType = "animal_bodytype"
        case color = "animal_colour"
        case age = "animal_age"
        case sterilization = "animal_sterilization"
        case bacterin = "animal_bacterin"
        case foundPlace = "animal_foundplace"
        case status = "animal_status"
        case remark = "animal_remark"
        case openDate = "animal_opendate"
        case closedDate = "animal_closeddate"
        case updatedDate = "animal_update"
        case createdDate = "animal_createtime"
        case photoURL = "album_file"
        case address = "shelter_address"
        case telephone = "shelter_tel"
        case variety = "animal_Variety"
        case shelterName = "shelter_name"
    }
}