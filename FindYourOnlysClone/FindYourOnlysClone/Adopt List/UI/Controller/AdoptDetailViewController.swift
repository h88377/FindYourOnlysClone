//
//  AdoptDetailViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import UIKit

final class AdoptDetailViewController: UIViewController {
    
    // MARK: - Property
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        
        collectionView.register(AdoptDetailStatusInfoCell.self, forCellWithReuseIdentifier: AdoptDetailStatusInfoCell.identifier)
        collectionView.register(AdoptDetailMainInfoCell.self, forCellWithReuseIdentifier: AdoptDetailMainInfoCell.identifier)
        collectionView.register(AdoptDetailInfoCell.self, forCellWithReuseIdentifier: AdoptDetailInfoCell.identifier)
        collectionView.register(AdoptDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AdoptDetailHeaderView.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<AdoptDetailSection, AdoptDetailCellViewController> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, controller in
            let section = self?.sections[indexPath.section]
            let cell = controller.view(in: collectionView, indexPath: indexPath)
            return cell
        }
    }()
    
    private let image: UIImage?
    private let sections: [AdoptDetailSection]
    private let cellControllers: [AdoptDetailCellViewController]
    
    // MARK: - Life cycle
    
    init(image: UIImage?, sections: [AdoptDetailSection], cellControllers: [AdoptDetailCellViewController]) {
        self.image = image
        self.sections = sections
        self.cellControllers = cellControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       configureCollectionView()
    }
    
    // MARK: - Method
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return .init { [weak self] sectionIndex, _ in
            self?.sections[sectionIndex].sectionLayout()
        }
    }
    
    private func configureCollectionView() {
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AdoptDetailHeaderView.identifier, for: indexPath) as! AdoptDetailHeaderView
            header.imageView.image = self?.image
            
            return header
        }
        collectionView.dataSource = self.dataSource
        configureSnapshot()
    }
    
    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<AdoptDetailSection, AdoptDetailCellViewController>()
        snapshot.appendSections(sections)
        cellControllers.forEach { $0.append(in: &snapshot) }
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension AdoptDetailSection {
    private var identifier: String {
        switch self {
        case .status:
            return AdoptDetailStatusInfoCell.identifier
            
        case .mainInfo:
            return AdoptDetailMainInfoCell.identifier
            
        case .info:
            return AdoptDetailInfoCell.identifier
        }
    }
    
    func sectionLayout() -> NSCollectionLayoutSection {
        switch self {
        case .status:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
            
        case .mainInfo:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalWidth(1/3))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1/3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            
            let section = NSCollectionLayoutSection(group: group)
            return section
            
        case .info:
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}
