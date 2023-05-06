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
    
    static func adoptDetailComposedWith(image: UIImage?, pet: Pet) -> AdoptDetailViewController {
        let detailSections = AdoptDetailSection.allCases
        let cellControllers = adaptAdoptDetailInfoSectionsToCellControllers(with: pet)
        let adoptDetailVC = AdoptDetailViewController(image: image, sections: detailSections, cellControllers: cellControllers)
        return adoptDetailVC
    }
    
    private static func adaptPetsToCellControllersWith(_ pets: [Pet], imageLoader: PetImageDataLoader, select: @escaping (Pet, UIImage?) -> Void) -> [AdoptListCellViewController] {
        return pets.map { pet in
            let cellViewModel = AdoptListCellViewModel(pet: pet, imageLoader: imageLoader, imageTransformer: UIImage.init)
            cellViewModel.selectHandler = select
            let cellController = AdoptListCellViewController(viewModel: cellViewModel)
            return cellController
        }
    }
    
    private static func adaptAdoptDetailInfoSectionsToCellControllers(with pet: Pet) -> [AdoptDetailCellViewController] {
        let infoSections: [AdoptDetailInfoSection] = AdoptDetailStatusInfoSection.allCases + AdoptDetailMainInfoSection.allCases + AdoptDetailSubInfoSection.allCases
        let viewModels = infoSections.map { AdoptDetailCellViewModel(pet: pet, detailSection: $0) }
        let controllers = viewModels.map { AdoptDetailCellViewController(viewModel: $0) }
        return controllers
    }
}
