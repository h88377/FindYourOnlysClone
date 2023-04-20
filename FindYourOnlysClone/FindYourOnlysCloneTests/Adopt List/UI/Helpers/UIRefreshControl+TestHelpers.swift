//
//  UIRefreshControl+TestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import UIKit

extension UIRefreshControl {
    func simulateRefresh() {
        sendActions(for: .valueChanged)
    }
}
