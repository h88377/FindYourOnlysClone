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
        
        collectionView.register(AdoptDetailStatusCell.self, forCellWithReuseIdentifier: AdoptDetailStatusCell.identifier)
        collectionView.register(AdoptDetailMainInfoCell.self, forCellWithReuseIdentifier: AdoptDetailMainInfoCell.identifier)
        collectionView.register(AdoptDetailInfoCell.self, forCellWithReuseIdentifier: AdoptDetailInfoCell.identifier)
        collectionView.register(AdoptDetailHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AdoptDetailHeaderView.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<AdoptDetailSection, AdoptDetailModel> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, model in
            let section = self?.sections[indexPath.section]
            let cell = section?.cellForItemAt(collectionView, indexPath: indexPath, model: model)
            return cell
        }
    }()
    
    private let sections = AdoptDetailSection.allCases
    private let viewModel: AdoptDetailViewModel<UIImage>
    
    // MARK: - Life cycle
    
    init(viewModel: AdoptDetailViewModel<UIImage>) {
        self.viewModel = viewModel
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
    
    private func configureCollectionView() {
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AdoptDetailHeaderView.identifier, for: indexPath) as! AdoptDetailHeaderView
            header.imageView.image = self?.viewModel.petImage
            
            return header
        }
        collectionView.dataSource = self.dataSource
        configureSnapshot()
    }
    
    private func configureSnapshot() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(sections)
        
        let statusModel = [
            AdoptDetailModel(description: viewModel.statusText)
        ]
        snapshot.appendItems(statusModel, toSection: .status)
        
        let mainModels = [
            AdoptDetailModel(title: MainInfoSection.kind.rawValue, description: viewModel.kindText),
            AdoptDetailModel(title: MainInfoSection.gender.rawValue, description: viewModel.genderText),
            AdoptDetailModel(title: MainInfoSection.variety.rawValue, description: viewModel.varietyText)
        ]
        snapshot.appendItems(mainModels, toSection: .mainInfo)
        
        let infoModels = [
            AdoptDetailModel(title: InfoSection.id.rawValue, description: viewModel.idText),
            AdoptDetailModel(title: InfoSection.age.rawValue, description: viewModel.ageText),
            AdoptDetailModel(title: InfoSection.color.rawValue, description: viewModel.colorText),
            AdoptDetailModel(title: InfoSection.bodyType.rawValue, description: viewModel.bodyTypeText),
            AdoptDetailModel(title: InfoSection.foundPlace.rawValue, description: viewModel.foundPlaceText),
            AdoptDetailModel(title: InfoSection.sterilization.rawValue, description: viewModel.sterilizationText),
            AdoptDetailModel(title: InfoSection.bacterin.rawValue, description: viewModel.bacterinText),
            AdoptDetailModel(title: InfoSection.openDate.rawValue, description: viewModel.openForAdoptionDateText),
            AdoptDetailModel(title: InfoSection.closedDate.rawValue, description: viewModel.closeForAdoptionDateText),
            AdoptDetailModel(title: InfoSection.updatedDate.rawValue, description: viewModel.updatedDateText),
            AdoptDetailModel(title: InfoSection.createdDate.rawValue, description: viewModel.createdDateText),
            AdoptDetailModel(title: InfoSection.shelterName.rawValue, description: viewModel.shelterNameText),
            AdoptDetailModel(title: InfoSection.address.rawValue, description: viewModel.addressText),
            AdoptDetailModel(title: InfoSection.telephone.rawValue, description: viewModel.telephoneText),
            AdoptDetailModel(title: InfoSection.remark.rawValue, description: viewModel.remarkText),
        ]
        snapshot.appendItems(infoModels, toSection: .info)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return .init { [weak self] sectionIndex, _ in
            self?.sections[sectionIndex].sectionLayout()
        }
    }
}

extension AdoptDetailViewController {
    struct AdoptDetailModel: Hashable {
        let title: String?
        let description: String
        
        init(title: String? = nil, description: String) {
            self.title = title
            self.description = description
        }
    }
    
    enum AdoptDetailSection: Int, Hashable, CaseIterable {
        case status
        case mainInfo
        case info
        
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
        
        func cellForItemAt(_ collectionView: UICollectionView, indexPath: IndexPath, model: AdoptDetailModel) -> UICollectionViewCell {
            switch self {
            case .status:
                let cell: AdoptDetailStatusCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.statusLabel.text = model.description
                return cell
                
            case .mainInfo:
                let cell: AdoptDetailMainInfoCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.infoTitleLabel.text = model.title
                cell.infoLabel.text = model.description
                return cell
                
            case .info:
                let cell: AdoptDetailInfoCell = collectionView.dequeueReusableCell(for: indexPath)
                cell.infoTitleLabel.text = model.title
                cell.infoLabel.text = model.description
                return cell
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
    
    enum MainInfoSection: String, CaseIterable {
        case kind = "種類"
        case gender = "性別"
        case variety = "品種"
    }
    
    enum InfoSection: String, CaseIterable {
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
}
