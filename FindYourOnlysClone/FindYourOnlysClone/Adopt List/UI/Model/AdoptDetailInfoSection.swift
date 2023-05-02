//
//  AdoptDetailInfoSection.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import Foundation

enum AdoptDetailSection: Int, Hashable, CaseIterable {
    case status
    case mainInfo
    case info
}

protocol AdoptDetailInfoSection {}

enum StatusSection: CaseIterable, AdoptDetailInfoSection {
    case status
}

enum MainInfoSection: String, CaseIterable, AdoptDetailInfoSection {
    case kind = "種類"
    case gender = "性別"
    case variety = "品種"
}

enum SubInfoSection: String, CaseIterable, AdoptDetailInfoSection {
    case id = "動物流水編號"
    case age = "動物年齡"
    case color = "動物毛色"
    case bodyType = "動物體型"
    case foundPlace = "尋獲地點"
    case sterilization = "是否節育"
    case bacterin = "是否打狂犬疫苗"
    case openDate = "開放領養時間"
    case closedDate = "截止領養時間"
    case updatedDate = "資料更新時間"
    case createdDate = "資料建立時間"
    case shelterName = "領養機構"
    case address = "領養地址"
    case telephone = "領養電話"
    case remark = "備註"
}
