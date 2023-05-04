//
//  UIImage+Extension.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/3.
//

import UIKit

enum ImageAsset: String {
    case adoptListCellImagePlaceholder
}

enum SystemAsset: String {
    case mappinAndEllipse = "mappin.and.ellipse"
}

extension UIImage {
    static func make(byAsset asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
    
    static func make(bySystem system: SystemAsset) -> UIImage? {
        return UIImage(systemName: system.rawValue)
    }
}
