//
//  AdoptDetailViewController+TestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import UIKit
@testable import FindYourOnlysClone

extension AdoptDetailViewController {
    var statusSection: Int { return 0 }
    var mainInfoSection: Int { return 1 }
    var infoSection: Int { return 2 }
    
    var dataSourceIsConfigured: Bool {
        return collectionView.dataSource != nil
    }
    
    var headerImage: UIImage? {
        let header = collectionView.dataSource?.collectionView?(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0)) as? AdoptDetailHeaderView
        return header?.imageView.image
    }
    
    @discardableResult
    func simulatePetInfoIsVisibleAt(indexPath: IndexPath) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func simulateHeaderIsVisible() {
        simulatePetInfoIsVisibleAt(indexPath: IndexPath(item: 0, section: statusSection))
    }
}
