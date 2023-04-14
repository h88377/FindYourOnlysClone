//
//  AdoptListPetCell.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListCell: UICollectionViewCell {
    let kindLabel = UILabel()
    let genderLabel = UILabel()
    let cityLabel = UILabel()
    let petImageView = UIImageView()
    let petImageContainer = UIView()
    
    private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryImageLoad), for: .touchUpInside)
        
        return button
    }()
    
    var retryImageLoadHandler: (() -> Void)?
    
    @objc private func retryImageLoad() {
        retryImageLoadHandler?()
    }
}
