//
//  AdoptListPetCell.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListCell: UICollectionViewCell {
    
    // MARK: - Property
    
    private let baseView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let kindLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .darkGray
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let genderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .darkGray
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let locationIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.tintColor = .projectIconColor
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let petImageContainer: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "adoptListCellImagePlaceholder")

        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryImageLoad), for: .touchUpInside)
        button.setTitle("↻", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        button.setTitleColor(.darkGray, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var retryImageLoadHandler: (() -> Void)?
    var prepareForReuseHandler: (() -> Void)?
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseView.layer.cornerRadius = 12
        petImageContainer.layer.cornerRadius = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        prepareForReuseHandler?()
    }
    
    // MARK: - Method
    
    private func setUpUI() {
        contentView.backgroundColor = .systemGray6
        
        contentView.addSubview(baseView)
        baseView.addSubviews([kindLabel, genderLabel, cityLabel, locationIconView, petImageContainer])
        petImageContainer.addSubviews([petImageView, retryButton])
        
        kindLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        NSLayoutConstraint.activate([
            baseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: contentView.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            kindLabel.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 16),
            kindLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 16),

            genderLabel.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -16),
            genderLabel.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 16),

            locationIconView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 16),
            locationIconView.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 16),
            locationIconView.widthAnchor.constraint(equalToConstant: 16),
            locationIconView.heightAnchor.constraint(equalToConstant: 16),

            cityLabel.leadingAnchor.constraint(equalTo: locationIconView.trailingAnchor, constant: 10),
            cityLabel.bottomAnchor.constraint(equalTo: locationIconView.bottomAnchor),

            petImageContainer.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            petImageContainer.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            petImageContainer.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
            petImageContainer.topAnchor.constraint(equalTo: locationIconView.bottomAnchor, constant: 10),

            petImageView.leadingAnchor.constraint(equalTo: petImageContainer.leadingAnchor),
            petImageView.trailingAnchor.constraint(equalTo: petImageContainer.trailingAnchor),
            petImageView.topAnchor.constraint(equalTo: petImageContainer.topAnchor),
            petImageView.bottomAnchor.constraint(equalTo: petImageContainer.bottomAnchor),
            
            retryButton.leadingAnchor.constraint(equalTo: petImageContainer.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: petImageContainer.trailingAnchor),
            retryButton.topAnchor.constraint(equalTo: petImageContainer.topAnchor),
            retryButton.bottomAnchor.constraint(equalTo: petImageContainer.bottomAnchor)
        ])
        
    }
    
    @objc private func retryImageLoad() {
        retryImageLoadHandler?()
    }
}


