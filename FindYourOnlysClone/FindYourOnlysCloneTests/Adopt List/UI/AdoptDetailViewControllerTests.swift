//
//  AdoptDetailViewControllerTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/30.
//

import XCTest
@testable import FindYourOnlysClone

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
