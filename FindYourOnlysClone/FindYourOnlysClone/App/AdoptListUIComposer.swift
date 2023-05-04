//
//  AdoptListUIComposer.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListUIComposer {
    private init() {}
    
    static func adoptListComposedWith(petLoader: PetLoader, imageLoader: PetImageDataLoader, select: @escaping (Pet, UIImage?) -> Void) -> AdoptListViewController {
        let decoratedPetLoader = MainThreadDispatchDecorator(decoratee: petLoader)
        let decoratedImageLoader = MainThreadDispatchDecorator(decoratee: imageLoader)
        
        let paginationViewModel = AdoptListPaginationViewModel(petLoader: decoratedPetLoader)
        let paginationController = AdoptListPaginationViewController(viewModel: paginationViewModel)
        
        let adoptListViewModel = AdoptListViewModel(petLoader: MainThreadDispatchDecorator(decoratee: petLoader))
        let adoptListController = AdoptListViewController(viewModel: adoptListViewModel, paginationController: paginationController)
        
        adoptListViewModel.isPetsRefreshingStateOnChange = { [weak adoptListController] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: decoratedImageLoader, select: select)
            adoptListController?.set(cellControllers)
            adoptListController?.noResultReminder.isHidden = !pets.isEmpty
        }
        
        paginationViewModel.isPetsPaginationStateOnChange = { [weak adoptListController] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: decoratedImageLoader, select: select)
            adoptListController?.append(cellControllers)
        }
        
        paginationViewModel.isPetsPaginationErrorStateOnChange = { [weak adoptListController] message in
            guard let adoptListController = adoptListController else { return }
            
            adoptListController.errorView.show(message, on: adoptListController.view)
        }
        
        return adoptListController
    }
    
    private static func adaptPetsToCellControllersWith(_ pets: [Pet], imageLoader: PetImageDataLoader, select: @escaping (Pet, UIImage?) -> Void) -> [AdoptListCellViewController] {
        return pets.map { pet in
            let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: imageLoader, imageTransformer: UIImage.init)
            cellViewModel.selectHandler = select
            let cellController = AdoptListCellViewController(viewModel: cellViewModel)
            return cellController
        }
    }
}
