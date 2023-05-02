//
//  AdoptDetailCellViewModel.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import Foundation

struct AdoptDetailCellViewModel: Hashable {
    let title: String?
    let description: String
    
    init(title: String? = nil, description: String) {
        self.title = title
        self.description = description
    }
}
