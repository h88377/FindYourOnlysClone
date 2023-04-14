//
//  AdoptListViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListViewController: UICollectionViewController {
    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, Pet> = {
        .init(collectionView: collectionView) { collectionView, indexPath, pet in
            let cell = AdoptListCell()
            cell.genderLabel.text = pet.gender == "M" ? "♂" : "♀"
            cell.kindLabel.text = pet.kind
            cell.cityLabel.text = String(pet.address[...2])
            return cell
        }
    }()
    
    private var request = AdoptPetRequest(page: 0)
    private var loader: PetLoader?
    
    convenience init(loader: PetLoader) {
        self.init(collectionViewLayout: UICollectionViewLayout())
        self.loader = loader
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
    
    private func set(_ newItems: [Pet]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Pet>()
        snapshot.appendSections([0])
        snapshot.appendItems(newItems, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
