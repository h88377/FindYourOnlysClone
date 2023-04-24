//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListViewController: UICollectionViewController {
    
    // MARK: - Property
    
    private let viewModel: AdoptListViewModel
    private let paginationController: AdoptListPaginationViewController
    
    init(viewModel: AdoptListViewModel, paginationController: AdoptListPaginationViewController) {
        self.viewModel = viewModel
        self.paginationController = paginationController
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    let errorView: ErrorView = {
        let view = ErrorView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var petsSection: Int { return 0 }
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, AdoptListCellViewController> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, controller in
            return controller.view(in: collectionView, at: indexPath)
        }
    }()
    
    // MARK: - Life cycle
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpBinding()
        configureCollectionView()
        loadPets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        errorView.layer.cornerRadius = 20
    }
    
    // MARK: - Method
    
    func set(_ newItems: [AdoptListCellViewController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, AdoptListCellViewController>()
        snapshot.appendSections([petsSection])
        snapshot.appendItems(newItems, toSection: petsSection)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func append(_ newItems: [AdoptListCellViewController]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newItems, toSection: petsSection)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .systemGray6
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.dataSource = self.dataSource
        collectionView.prefetchDataSource = self
        collectionView.register(AdoptListCell.self, forCellWithReuseIdentifier: AdoptListCell.identifier)
        collectionView.refreshControl = binded(refreshView: UIRefreshControl())
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(290))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(290))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func binded(refreshView: UIRefreshControl) -> UIRefreshControl {
        viewModel.isPetRefreshLoadingStateOnChange = { [weak self] isLoading in
            if isLoading {
                self?.collectionView.refreshControl?.beginRefreshing()
            } else {
                self?.collectionView?.refreshControl?.endRefreshing()
            }
        }
        refreshView.addTarget(self, action: #selector(loadPets), for: .valueChanged)
        
        return refreshView
    }
    
    private func setUpBinding() {
        viewModel.isPetsRefreshingErrorStateOnChange = { [weak self] message in
            guard let self = self else { return }
            
            self.errorView.show(message, on: self.view)
        }
    }
    
    @objc private func loadPets() {
        paginationController.resetPage()
        viewModel.refreshPets()
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
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        paginationController.paginate(on: scrollView)
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
