//
//  AdoptDetailViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import UIKit

final class AdoptDetailCellViewController {
    private let id = UUID()
    private let viewModel: AdoptDetailCellViewModel
    
    init(viewModel: AdoptDetailCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch viewModel.detailSection {
        case is StatusSection:
            let cell: AdoptDetailStatusCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.statusLabel.text = viewModel.descriptionText
            return cell
            
        case is MainInfoSection:
            let cell: AdoptDetailMainInfoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.infoTitleLabel.text = viewModel.titleText
            cell.infoLabel.text = viewModel.descriptionText
            return cell
            
        case is SubInfoSection:
            let cell: AdoptDetailInfoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.infoTitleLabel.text = viewModel.titleText
            cell.infoLabel.text = viewModel.descriptionText
            return cell
            
        default: return nil
        }
    }
    
    func append(in snapshot: inout NSDiffableDataSourceSnapshot<AdoptDetailSection, AdoptDetailCellViewController>) {
        switch viewModel.detailSection {
        case is StatusSection:
            snapshot.appendItems([self], toSection: .status)
            
        case is MainInfoSection:
            snapshot.appendItems([self], toSection: .mainInfo)
            
        case is SubInfoSection:
            snapshot.appendItems([self], toSection: .info)
            
        default: break
        }
    }
}

extension AdoptDetailCellViewController: Hashable {
    static func == (lhs: AdoptDetailCellViewController, rhs: AdoptDetailCellViewController) -> Bool {
      lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
}

final class AdoptDetailViewController: UIViewController {
    
    // MARK: - Property
    
    private(set) lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        
        collectionView.register(AdoptDetailStatusCell.self, forCellWithReuseIdentifier: AdoptDetailStatusCell.identifier)
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
            return AdoptDetailStatusCell.identifier
            
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

enum AdoptDetailSection: Int, Hashable, CaseIterable {
    case status
    case mainInfo
    case info
}

protocol AdoptDetailInfoSection {}

enum StatusSection: AdoptDetailInfoSection, CaseIterable {
    case status
}

enum MainInfoSection: String, CaseIterable, AdoptDetailInfoSection {
    case kind = "種類"
    case gender = "性別"
    case variety = "品種"
}

enum SubInfoSection: String, CaseIterable, AdoptDetailInfoSection {
    case id = "動物流水編號"
    case age = "動物年齡"
    case color = "動物毛色"
    case bodyType = "動物體型"
    case foundPlace = "尋獲地點"
    case sterilization = "是否節育"
    case bacterin = "是否打狂犬疫苗"
    case openDate = "開放領養時間"
    case closedDate = "截止領養時間"
    case updatedDate = "資料更新時間"
    case createdDate = "資料建立時間"
    case shelterName = "領養機構"
    case address = "領養地址"
    case telephone = "領養電話"
    case remark = "備註"
}
