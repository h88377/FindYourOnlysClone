//
//  AdoptDetailInfoCell.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import UIKit

final class AdoptDetailInfoCell: UICollectionViewCell {
    let infoTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .left
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .right
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubviews([infoTitleLabel, infoLabel])
        
        NSLayoutConstraint.activate([
            infoTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoTitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            infoTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: infoLabel.leadingAnchor, constant: -10),
            
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}
