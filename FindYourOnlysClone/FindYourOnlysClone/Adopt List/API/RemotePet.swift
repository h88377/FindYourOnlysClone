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
    let openDate: String
    let closedDate: String
    let updatedDate: String
    let createdDate: String
    let photoURLString: String
    let address: String
    let telephone: String
    let variety: String
    let shelterName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "動物的流水編號"
        case location = "動物的實際所在地"
        case kind = "動物的類型"
        case gender = "動物性別"
        case bodyType = "動物體型"
        case color = "動物毛色"
        case age = "動物年紀"
        case sterilization = "是否絕育"
        case bacterin = "是否施打狂犬病疫苗"
        case foundPlace = "動物尋獲地"
        case status = "動物狀態"
        case remark = "資料備註"
        case openDate = "開放認養時間(起)"
        case closedDate = "開放認養時間(迄)"
        case updatedDate = "動物資料異動時間"
        case createdDate = "動物資料建立時間"
        case photoURLString = "圖片名稱"
        case address = "地址"
        case telephone = "連絡電話"
        case variety = "動物品種"
        case shelterName = "動物所屬收容所名稱"
    }
}
