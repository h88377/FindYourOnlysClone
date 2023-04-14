//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

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
    
    private var request = AdoptPetRequest(page: 0)
    private var loader: PetLoader?
    private var imageLoader: PetImageDataLoader?
    private var tasks = [IndexPath: PetImageDataLoaderTask]()
    
    convenience init(loader: PetLoader, imageLoader: PetImageDataLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadPets), for: .valueChanged)
        collectionView.dataSource = self.dataSource
        loadPets()
    }
    
    @objc private func loadPets() {
        collectionView.refreshControl?.beginRefreshing()
        loader?.load(with: request) { [weak self] result in
            if let pets = try? result.get() {
                self?.set(pets)
            }
            self?.collectionView?.refreshControl?.endRefreshing()
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
    
    private func set(_ newItems: [Pet]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Pet>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pet = dataSource.itemIdentifier(for: indexPath),
              let cell = cell as? AdoptListCell
        else { return }
        
        requestImageData(with: pet, in: cell, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
