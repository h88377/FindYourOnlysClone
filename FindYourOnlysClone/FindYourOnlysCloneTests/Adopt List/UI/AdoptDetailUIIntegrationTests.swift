//
//  AdoptDetailViewControllerTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/30.
//

import XCTest
@testable import FindYourOnlysClone

class AdoptDetailUIIntegrationTests: XCTestCase {
    
    func test_viewDidLoad_didConfigureDataSource() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.dataSourceIsConfigured)
    }
    
    func test_cellIsVisible_rendersPetInformation() {
        let (sut, viewModels) = makeSUT()

        sut.loadViewIfNeeded()
        
        expect(sut, isRenderingWhenCellIsVisible: viewModels)
    }
    
    func test_headerIsVisible_rendersPetImage() {
        let image = UIImage.make(withColor: .red)
        let (sut, _) = makeSUT(image: image)

        sut.loadViewIfNeeded()
        sut.simulateHeaderIsVisible()
        
        XCTAssertEqual(sut.headerImage, image)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(image: UIImage? = nil, file: StaticString = #filePath, line: UInt = #line) -> (AdoptDetailViewController, [AdoptDetailCellViewModel]) {
        let pet = makePet()
        let infoSections: [AdoptDetailInfoSection] = AdoptDetailStatusInfoSection.allCases + AdoptDetailMainInfoSection.allCases + AdoptDetailSubInfoSection.allCases
        let cellViewModels = infoSections.map { AdoptDetailCellViewModel(pet: pet, detailSection: $0) }
        let cellControllers = cellViewModels.map { AdoptDetailCellViewController(viewModel: $0) }
        let sut = AdoptDetailViewController(image: image, sections: AdoptDetailSection.allCases, cellControllers: cellControllers)
        
        trackForMemoryLeak(sut, file: file, line: line)
        cellViewModels.forEach { trackForMemoryLeak($0, file: file, line: line) }
        cellControllers.forEach { trackForMemoryLeak($0, file: file, line: line) }
        return (sut, cellViewModels)
    }
    
    private func expect(_ sut: AdoptDetailViewController, isRenderingWhenCellIsVisible viewModels: [AdoptDetailCellViewModel], file: StaticString = #filePath, line: UInt = #line) {
        let statusInfoCaseCount = AdoptDetailStatusInfoSection.allCases.count
        let mainInfoCaseCount = AdoptDetailMainInfoSection.allCases.count
        
        for (index, viewModel) in viewModels.enumerated() {
            switch viewModel.detailSection {
            case is AdoptDetailStatusInfoSection:
                expect(sut, hasStatusInfoViewConfiuredFor: viewModel, at: index, file: file, line: line)
                
            case is AdoptDetailMainInfoSection:
                let mainInfoIndex = index - statusInfoCaseCount
                expect(sut, hasMainInfoViewConfiuredFor: viewModel, at: mainInfoIndex, file: file, line: line)
                
            case is AdoptDetailSubInfoSection:
                let subInfoIndex = index - statusInfoCaseCount - mainInfoCaseCount
                expect(sut, hasSubInfoViewConfiuredFor: viewModel, at: subInfoIndex, file: file, line: line)
                
            default: XCTFail("Unexpected infoSection", file: file, line: line)
            }
        }
    }
    
    private func expect(_ sut: AdoptDetailViewController, hasStatusInfoViewConfiuredFor viewModel: AdoptDetailCellViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: index, section: sut.statusSection))
        guard let cell = view as? AdoptDetailStatusInfoCell else {
            return XCTFail("Expected cell instance \(AdoptDetailStatusInfoCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.statusLabel.text, viewModel.descriptionText, "Expected description text should be  \(viewModel.descriptionText)", file: file, line: line)
    }
    
    private func expect(_ sut: AdoptDetailViewController, hasMainInfoViewConfiuredFor viewModel: AdoptDetailCellViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: index, section: sut.mainInfoSection))
        guard let cell = view as? AdoptDetailMainInfoCell else {
            return XCTFail("Expected cell instance \(AdoptDetailMainInfoCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.infoTitleLabel.text, viewModel.titleText, "Expected title text should be  \(String(describing: viewModel.titleText))", file: file, line: line)
        XCTAssertEqual(cell.infoLabel.text, viewModel.descriptionText, "Expected description text should be  \(viewModel.descriptionText)", file: file, line: line)
    }
    
    private func expect(_ sut: AdoptDetailViewController, hasSubInfoViewConfiuredFor viewModel: AdoptDetailCellViewModel, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: index, section: sut.infoSection))
        guard let cell = view as? AdoptDetailInfoCell else {
            return XCTFail("Expected cell instance \(AdoptDetailInfoCell.self), got \(String(describing: view.self)) instance instead", file: file, line: line)
        }
        
        XCTAssertEqual(cell.infoTitleLabel.text, viewModel.titleText, "Expected title text should be  \(String(describing: viewModel.titleText))", file: file, line: line)
        XCTAssertEqual(cell.infoLabel.text, viewModel.descriptionText, "Expected description text should be  \(viewModel.descriptionText)", file: file, line: line)
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
