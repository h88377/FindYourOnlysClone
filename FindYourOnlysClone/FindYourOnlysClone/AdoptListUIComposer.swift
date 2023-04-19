//
//  AdoptListUIComposer.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListUIComposer {
    private init() {}
    
    static func adoptListComposedWith(petLoader: PetLoader, imageLoader: PetImageDataLoader) -> AdoptListViewController {
        let viewModel = AdoptListViewModel(petLoader: MainThreadDispatchDecorator(decoratee: petLoader))
        let controller = AdoptListViewController(viewModel: viewModel)
        
        viewModel.isPetsRefreshingStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: imageLoader)
            controller?.set(cellControllers)
        }
        
        viewModel.isPetsAppendingStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: imageLoader)
            controller?.append(cellControllers)
        }
        
        return controller
    }
    
    private static func adaptPetsToCellControllersWith(_ pets: [Pet], imageLoader: PetImageDataLoader) -> [AdoptListCellViewController] {
        return pets.map { pet in
            let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: imageLoader, imageTransformer: UIImage.init)
            let cellController = AdoptListCellViewController(viewModel: cellViewModel)
            return cellController
        }
    }
}

private final class MainThreadDispatchDecorator: PetLoader {
    private let decoratee: PetLoader
    
    init(decoratee: PetLoader) {
        self.decoratee = decoratee
    }
    
    func load(with request: AdoptListRequest, completion: @escaping (PetLoader.Result) -> Void) {
        decoratee.load(with: request) { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
