//
//  UICollectionView+Extension.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/16.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}
