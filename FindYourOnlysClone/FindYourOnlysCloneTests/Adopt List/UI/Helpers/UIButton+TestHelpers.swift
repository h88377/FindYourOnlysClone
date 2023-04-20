//
//  UIButton+TestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import UIKit

extension UIButton {
    func simulateTap() {
        sendActions(for: .touchUpInside)
    }
}
