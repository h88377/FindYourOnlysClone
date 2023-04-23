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
        let decoratedImageLoader = MainThreadDispatchDecorator(decoratee: imageLoader)
        
        viewModel.isPetsRefreshingStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: decoratedImageLoader)
            controller?.set(cellControllers)
        }
        
        viewModel.isPetsPaginationStateOnChange = { [weak controller] pets in
            let cellControllers = adaptPetsToCellControllersWith(pets, imageLoader: decoratedImageLoader)
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

private final class MainThreadDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }
        
        completion()
    }
}

extension MainThreadDispatchDecorator: PetLoader where T == PetLoader {
    func load(with request: AdoptListRequest, completion: @escaping (PetLoader.Result) -> Void) {
        decoratee.load(with: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainThreadDispatchDecorator: PetImageDataLoader where T == PetImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (PetImageDataLoader.Result) -> Void) -> PetImageDataLoaderTask {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
