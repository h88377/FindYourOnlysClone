//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListPaginationViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private let petLoader: PetLoader
    
    init(petLoader: PetLoader) {
        self.petLoader = petLoader
    }
    
    private var currentPage = 0
    var isPetPaginationLoadingStateOnChange: Observer<Bool>?
    var isPetsPaginationStateOnChange: Observer<[Pet]>?
    
    func resetPage() {
        currentPage = 0
    }
    
    func loadNextPage() {
        currentPage += 1
        isPetPaginationLoadingStateOnChange?(true)
        petLoader.load(with: AdoptListRequest(page: currentPage)) { [weak self] result in
            if let pets = try? result.get() {
                self?.isPetsPaginationStateOnChange?(pets)
            }
            self?.isPetPaginationLoadingStateOnChange?(false)
        }
    }
    
}

final class AdoptListPaginationViewController {
    private let viewModel: AdoptListPaginationViewModel
    
    init(viewModel: AdoptListPaginationViewModel) {
        self.viewModel = viewModel
        self.setUpBinding()
    }
    
    private var isPaginating = false
    
    func resetPage() {
        viewModel.resetPage()
    }
     
    func paginate(on scrollView: UIScrollView) {
        guard scrollView.isDragging, !isPaginating else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > (contentHeight - frameHeight) {
            viewModel.loadNextPage()
        }
    }
    
    private func setUpBinding() {
        viewModel.isPetPaginationLoadingStateOnChange = { [weak self] isPaginating in
            self?.isPaginating = isPaginating
        }
    }
}

final class AdoptListViewController: UICollectionViewController {
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, AdoptListCellViewController> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, controller in
            return controller.view(in: collectionView, at: indexPath)
        }
    }()
    
    private var petsSection: Int { return 0 }
    
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
    
    private let viewModel: AdoptListViewModel
    private let paginationController: AdoptListPaginationViewController
    
    init(viewModel: AdoptListViewModel, paginationController: AdoptListPaginationViewController) {
        self.viewModel = viewModel
        self.paginationController = paginationController
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        loadPets()
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
