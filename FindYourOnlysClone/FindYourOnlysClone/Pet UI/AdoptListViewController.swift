//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private var petLoader: PetLoader?
    
    var isPetLoadingStateOnChange: Observer<Bool>?
    var isPetsAppendingStateOnChange: Observer<[Pet]>?
    var isPetsRefreshingStateOnChange: Observer<[Pet]>?
    
    init(petLoader: PetLoader) {
        self.petLoader = petLoader
    }
    
    func loadPets(with page: Int) {
        isPetLoadingStateOnChange?(true)
        petLoader?.load(with: AdoptPetRequest(page: page)) { [weak self] result in
            if let pets = try? result.get() {
                if page == 0 {
                    self?.isPetsRefreshingStateOnChange?(pets)
                } else {
                    self?.isPetsAppendingStateOnChange?(pets)
                }
            }
            self?.isPetLoadingStateOnChange?(false)
        }
    }
}

class AdoptListViewController: UICollectionViewController {
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Pet> = {
        .init(collectionView: collectionView) { [weak self] collectionView, indexPath, pet in
            let cell = AdoptListCell()
            cell.genderLabel.text = pet.gender == "M" ? "♂" : "♀"
            cell.kindLabel.text = pet.kind
            cell.cityLabel.text = String(pet.address[...2])
            cell.retryImageLoadHandler = { [weak self, weak cell] in
                self?.requestImageData(with: pet, in: cell, at: indexPath)
            }
            return cell
        }
    }()
    
    private func set(_ newItems: [Pet]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Pet>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func append(_ newItems: [Pet]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private var viewModel: AdoptListViewModel?
    private var imageLoader: PetImageDataLoader?
    private var currentPage = 0
    private var tasks = [IndexPath: PetImageDataLoaderTask]()
    
    convenience init(viewModel: AdoptListViewModel, imageLoader: PetImageDataLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBinding()
        collectionView.refreshControl = binded(refreshView: UIRefreshControl())
        collectionView.dataSource = self.dataSource
        collectionView.prefetchDataSource = self
        loadPets()
    }
    
    @objc private func loadPets() {
        currentPage = 0
        viewModel?.loadPets(with: currentPage)
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
    
    private func setupBinding() {
        viewModel?.isPetsRefreshingStateOnChange = { [weak self] pets in
            self?.set(pets)
        }
        
        viewModel?.isPetsAppendingStateOnChange = { [weak self] pets in
            self?.append(pets)
        }
    }
    
    private func requestImageData(with pet: Pet, in cell: AdoptListCell?, at indexPath: IndexPath) {
        cell?.retryButton.isHidden = true
        cell?.petImageContainer.isShimmering = true
        tasks[indexPath] = imageLoader?.loadImageData(from: pet.photoURL) { [weak cell] result in
            if let image = (try? result.get()).flatMap(UIImage.init) {
                cell?.petImageView.image = image
            } else {
                cell?.retryButton.isHidden = false
            }
            cell?.petImageContainer.isShimmering = false
        }
    }
    
    private func cancelTask(forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

// MARK: - UICollectionViewDelegate

extension AdoptListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pet = dataSource.itemIdentifier(for: indexPath), let cell = cell as? AdoptListCell else { return }
        
        requestImageData(with: pet, in: cell, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cancelTask(forItemAt: indexPath)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if (offsetY > contentHeight - scrollView.frame.height) {
            currentPage += 1
            viewModel?.loadPets(with: currentPage)
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension AdoptListViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let pet = dataSource.itemIdentifier(for: indexPath) else { return }
            tasks[indexPath] = imageLoader?.loadImageData(from: pet.photoURL) { _ in }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
}
