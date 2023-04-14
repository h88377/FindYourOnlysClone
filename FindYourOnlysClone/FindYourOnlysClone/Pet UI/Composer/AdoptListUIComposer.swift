//
//  AdoptListUIComposer.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListUIComposer {
    private init() {}
    
    static func adoptListComposedWith(petLoader: PetLoader, imageLoader: PetImageDataLoader) -> AdoptListViewController {
        let viewModel = AdoptListViewModel(petLoader: petLoader)
        let controller = AdoptListViewController(viewModel: viewModel)
        
        viewModel.isPetsRefreshingStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, petLoader: petLoader, imageLoader: imageLoader)
            controller?.set(cellControllers)
        }
        
        viewModel.isPetsAppendingStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, petLoader: petLoader, imageLoader: imageLoader)
            controller?.append(cellControllers)
        }
        
        return controller
    }
    
    private static func adaptPetsToCellControllersWith(_ pets: [Pet], petLoader: PetLoader, imageLoader: PetImageDataLoader) -> [AdoptListCellViewController] {
        return pets.map { pet in
            let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: imageLoader, imageTransformer: UIImage.init)
            let cellController = AdoptListCellViewController(viewModel: cellViewModel)
            return cellController
        }
    }
}
