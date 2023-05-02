//
//  AdoptDetailViewControllerTests.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/30.
//

import XCTest
@testable import FindYourOnlysClone

final class AdoptDetailStatusCell: UICollectionViewCell {
    let statusLabel = UILabel()
}

final class AdoptDetailMainInfoCell: UICollectionViewCell {
    let infoTitleLabel = UILabel()
    let infoLabel = UILabel()
}

final class AdoptDetailInfoCell: UICollectionViewCell {
    let infoTitleLabel = UILabel()
    let infoLabel = UILabel()
}

final class AdoptDetailViewController: UIViewController {
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let sections = AdoptDetailSection.allCases
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<AdoptDetailSection, AdoptDetailModel> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, model in
            let section = self?.sections[indexPath.section]
            let cell = section?.cellForItemAt(collectionView, indexPath: indexPath, model: model)
            return cell
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self.dataSource
    }
}

private extension AdoptDetailViewController {
    struct AdoptDetailModel: Hashable {
        let title: String
        let description: String
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
}

class AdoptDetailViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_didConfigureDataSource() {
        let sut = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.dataSourceIsConfigured)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> AdoptDetailViewController {
        let sut = AdoptDetailViewController()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
}

extension AdoptDetailViewController {
    var dataSourceIsConfigured: Bool {
        return collectionView.dataSource != nil
    }
}
