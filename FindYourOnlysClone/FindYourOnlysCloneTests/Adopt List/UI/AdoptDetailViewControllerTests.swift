//
//  AdoptDetailViewControllerTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/30.
//

import XCTest
@testable import FindYourOnlysClone

final class AdoptDetailInfoCell: UICollectionViewCell {
    let infoTitleLabel = UILabel()
    let infoLabel = UILabel()
}

final class AdoptDetailViewController: UIViewController {
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.register(AdoptDetailStatusCell.self, forCellWithReuseIdentifier: AdoptDetailStatusCell.identifier)
        collectionView.register(AdoptDetailMainInfoCell.self, forCellWithReuseIdentifier: AdoptDetailMainInfoCell.identifier)
        collectionView.register(AdoptDetailInfoCell.self, forCellWithReuseIdentifier: AdoptDetailInfoCell.identifier)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let sections = AdoptDetailSection.allCases
    private let viewModel: AdoptDetailViewModel
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<AdoptDetailSection, AdoptDetailModel> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, model in
            let section = self?.sections[indexPath.section]
            let cell = section?.cellForItemAt(collectionView, indexPath: indexPath, model: model)
            return cell
        }
    }()
    
    init(viewModel: AdoptDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // apply
        dataSource.apply(snapshot, animatingDifferences: false)
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
    
    enum AdoptDetailSection: Hashable, CaseIterable {
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

class AdoptDetailViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_didConfigureDataSource() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.dataSourceIsConfigured)
    }
    
    func test_cellIsVisible_rendersPetInformation() {
        let pet = makePet()
        let viewModel = AdoptDetailViewModel(pet: pet)
        let sut = AdoptDetailViewController(viewModel: viewModel)

        sut.loadViewIfNeeded()
        
        expect(sut, isRenderingWhenCellIsVisible: viewModel)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(pet: Pet = Pet(id: 0, location: "新北市XX", kind: "貓", gender: "F", bodyType: "SMALL", color: "黑", age: "CHILD", sterilization: "T", bacterin: "F", foundPlace: "新北市FoundPlace", status: "OPEN", remark: "", openDate: "2023-04-22", closedDate: "2023-04-22", updatedDate: "2023-04-22", createdDate: "2023-04-22", photoURL: nil, address: "新北市XXX", telephone: "02-XXXXXXXX", variety: "混種", shelterName: "新北市收容所"), image: UIImage? = nil, file: StaticString = #filePath, line: UInt = #line) -> AdoptDetailViewController {
        let viewModel = AdoptDetailViewModel(pet: pet)
        let sut = AdoptDetailViewController(viewModel: viewModel)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(viewModel, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: AdoptDetailViewController, isRenderingWhenCellIsVisible viewModel: AdoptDetailViewModel, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: 0, section: sut.statusSection))
        guard let statusCell = view as? AdoptDetailStatusCell else {
            return XCTFail("Expected cell instance \(AdoptDetailStatusCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        XCTAssertEqual(statusCell.statusLabel.text, viewModel.statusText, "Expected status should be \(viewModel.statusText)", file: file, line: line)
        
        for (index, mainInfo) in AdoptDetailViewController.MainInfoSection.allCases.enumerated() {
            expect(sut, hasMainInfoViewConfiuredFor: viewModel, mainInfo: mainInfo, at: index, file: file, line: line)
        }
        
        for (index, info) in AdoptDetailViewController.InfoSection.allCases.enumerated() {
            expect(sut, hasInfoViewConfiuredFor: viewModel, info: info, at: index, file: file, line: line)
        }
    }
    
    private func expect(_ sut: AdoptDetailViewController, hasMainInfoViewConfiuredFor viewModel: AdoptDetailViewModel, mainInfo: AdoptDetailViewController.MainInfoSection, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: index, section: sut.mainInfoSection))
        guard let cell = view as? AdoptDetailMainInfoCell else {
            return XCTFail("Expected cell instance \(AdoptDetailMainInfoCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        
        let viewModelText: String
        switch mainInfo {
        case .kind:
            viewModelText = viewModel.kindText
            
        case .gender:
            viewModelText = viewModel.genderText
            
        case .variety:
            viewModelText = viewModel.varietyText
        }
        
        XCTAssertEqual(cell.infoTitleLabel.text, mainInfo.rawValue, "Expected \(mainInfo) title text should be  \(mainInfo.rawValue)", file: file, line: line)
        XCTAssertEqual(cell.infoLabel.text, viewModelText, "Expected \(mainInfo) info text should be  \(viewModelText)", file: file, line: line)
    }
    
    private func expect(_ sut: AdoptDetailViewController, hasInfoViewConfiuredFor viewModel: AdoptDetailViewModel, info: AdoptDetailViewController.InfoSection, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: index, section: sut.infoSection))
        guard let cell = view as? AdoptDetailInfoCell else {
            return XCTFail("Expected cell instance \(AdoptDetailInfoCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        
        let viewModelText: String
        switch info {
        case .id:
            viewModelText = viewModel.idText
            
        case .age:
            viewModelText = viewModel.ageText
            
        case .color:
            viewModelText = viewModel.colorText
            
        case .bodyType:
            viewModelText = viewModel.bodyTypeText
            
        case .foundPlace:
            viewModelText = viewModel.foundPlaceText
            
        case .sterilization:
            viewModelText = viewModel.sterilizationText
            
        case .bacterin:
            viewModelText = viewModel.bacterinText
            
        case .openDate:
            viewModelText = viewModel.openForAdoptionDateText
            
        case .closedDate:
            viewModelText = viewModel.closeForAdoptionDateText
            
        case .updatedDate:
            viewModelText = viewModel.updatedDateText
            
        case .createdDate:
            viewModelText = viewModel.createdDateText
        case .shelterName:
            viewModelText = viewModel.shelterNameText
            
        case .address:
            viewModelText = viewModel.addressText
            
        case .telephone:
            viewModelText = viewModel.telephoneText
            
        case .remark:
            viewModelText = viewModel.remarkText
        }
        
        XCTAssertEqual(cell.infoTitleLabel.text, info.rawValue, "Expected \(info) title text should be  \(info.rawValue)", file: file, line: line)
        XCTAssertEqual(cell.infoLabel.text, viewModelText, "Expected \(info) info text should be  \(viewModelText)", file: file, line: line)
    }
    
    private func makePet(id: Int = 0, location: String = "新北市XX", kind: String = "貓", gender: String = "F", bodyType: String = "SMALL", color: String = "黑", age: String = "CHILD", sterilization: String = "T", bacterin: String = "F", foundPlace: String = "新北市FoundPlace", status: String = "OPEN", remark: String = "", openDate: String = "2023-04-22", closedDate: String = "2023-04-22", updatedDate: String = "2023-04-22", createdDate: String = "2023-04-22", photoURL: URL? = nil, address: String = "新北市XXX", telephone: String = "02-XXXXXXXX", variety: String = "混種", shelterName: String = "新北市收容所") -> Pet {
        let pet = Pet(
            id: id,
            location: location,
            kind: kind,
            gender: gender,
            bodyType: bodyType,
            color: color,
            age: age,
            sterilization: sterilization,
            bacterin: bacterin,
            foundPlace: foundPlace,
            status: status,
            remark: remark,
            openDate: openDate,
            closedDate: closedDate,
            updatedDate: updatedDate,
            createdDate: createdDate,
            photoURL: photoURL,
            address: address,
            telephone: telephone,
            variety: variety,
            shelterName: shelterName)
        return pet
    }
}

extension AdoptDetailViewController {
    var statusSection: Int { return 0 }
    var mainInfoSection: Int { return 1 }
    var infoSection: Int { return 2 }
    
    var dataSourceIsConfigured: Bool {
        return collectionView.dataSource != nil
    }
    
    func simulatePetInfoIsVisibleAt(indexPath: IndexPath) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
    }
}
