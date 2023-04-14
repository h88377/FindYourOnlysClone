//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListViewController: UICollectionViewController {
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, AdoptListCellViewController> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, controller in
            return controller.view()
        }
    }()
    
    func set(_ newItems: [AdoptListCellViewController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AdoptListCellViewController>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func append(_ newItems: [AdoptListCellViewController]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private var viewModel: AdoptListViewModel?
    
    convenience init(viewModel: AdoptListViewModel) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = binded(refreshView: UIRefreshControl())
        collectionView.dataSource = self.dataSource
        collectionView.prefetchDataSource = self
        loadPets()
    }
    
    @objc private func loadPets() {
        viewModel?.refreshPets()
    }
    
    private func binded(refreshView: UIRefreshControl) -> UIRefreshControl {
        viewModel?.isPetLoadingStateOnChange = { [weak self] isLoading in
            if isLoading {
                self?.collectionView.refreshControl?.beginRefreshing()
            } else {
                self?.collectionView?.refreshControl?.endRefreshing()
            }
        }
        refreshView.addTarget(self, action: #selector(loadPets), for: .valueChanged)
        
        return refreshView
    }
    
    private func requestImageData(at indexPath: IndexPath) {
        cellController(at: indexPath)?.requestPetImageData()
    }
    
    private func cancelTask(forItemAt indexPath: IndexPath) {
        cellController(at: indexPath)?.cancelTask()
    }
    
    private func cellController(at indexPath: IndexPath) -> AdoptListCellViewController? {
        return dataSource.itemIdentifier(for: indexPath)
    }
}

// MARK: - UICollectionViewDelegate

extension AdoptListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        requestImageData(at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelTask(forItemAt: indexPath)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (offsetY > contentHeight - scrollView.frame.height) {
            viewModel?.loadNextPagePets()
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension AdoptListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            requestImageData(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}
