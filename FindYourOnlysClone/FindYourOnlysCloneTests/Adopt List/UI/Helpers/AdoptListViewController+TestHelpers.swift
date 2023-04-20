//
//  AdoptListViewController+TestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import UIKit
@testable import FindYourOnlysClone

extension AdoptListViewController {
    func simulateUserInitiatedPetsReload() {
        collectionView.refreshControl?.simulateRefresh()
    }
    
    @discardableResult
    func simulatePetImageViewIsVisible(at index: Int) -> AdoptListCell? {
        let cell = itemAt(index: index)!
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, willDisplay: cell, forItemAt: IndexPath(item: index, section: petsSection))
        return cell as? AdoptListCell
    }
    
    @discardableResult
    func simulatePetImageViewIsNotVisible(at index: Int) -> AdoptListCell {
        let cell = simulatePetImageViewIsVisible(at: index)!
        let delegate = collectionView.delegate
        delegate?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: IndexPath(item: index, section: petsSection))
        return cell
    }
    
    func simulatePetImageViewIsNearVisible(at index: Int) {
        let dataSource = collectionView.prefetchDataSource
        dataSource?.collectionView(collectionView, prefetchItemsAt: [IndexPath(item: index, section: petsSection)])
    }
    
    func simulatePetImageViewIsNotNearVisible(at index: Int) {
        simulatePetImageViewIsNearVisible(at: index)
        let dataSource = collectionView.prefetchDataSource
        dataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [IndexPath(item: index, section: petsSection)])
    }
    
    func simulatePaginationScrolling() {
        let scrollView = UIScrollView()
        scrollView.contentOffset.y = 1000
        scrollViewDidScroll(scrollView)
    }
    
    func itemAt(index: Int) -> UICollectionViewCell? {
        let dataSource = collectionView.dataSource
        let cell = dataSource?.collectionView(collectionView, cellForItemAt: IndexPath(item: index, section: petsSection))
        return cell
    }
    
    var isShowingLoadingIndicator: Bool {
        return collectionView.refreshControl?.isRefreshing == true
    }
    
    var numberOfPets: Int {
        return collectionView.numberOfSections == 0 ? 0 : collectionView.numberOfItems(inSection: petsSection)
    }
    
    private var petsSection: Int { return 0 }
}
