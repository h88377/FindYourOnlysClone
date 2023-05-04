//
//  UIStackView+Extension.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/3.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach(addArrangedSubview)
    }
}
