//
//  AdoptListCellViewModel.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import Foundation

final class AdoptListCellViewModel<Image> {
    typealias Observer<T> = ((T) -> Void)
    
    private let pet: Pet
    private let imageLoader: PetImageDataLoader
    private let imageTransformer: (Data) -> Image?
    private var task: PetImageDataLoaderTask?
    
    init(pet: Pet, imageLoader: PetImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.pet = pet
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var isPetImageLoadingStateOnChange: Observer<Bool>?
    var isPetImageStateOnChange: Observer<Image>?
    var isPetImageRetryStateOnChange: Observer<Bool>?
    
    func loadPetImageData() {
        guard let photoURL = pet.photoURL else { return }
        
        isPetImageLoadingStateOnChange?(true)
        isPetImageRetryStateOnChange?(false)
        task = imageLoader.loadImageData(from: photoURL) { [weak self] result in
            if let data = try? result.get(), let image = self?.imageTransformer(data) {
                self?.isPetImageStateOnChange?(image)
            } else {
                self?.isPetImageRetryStateOnChange?(true)
            }
            self?.isPetImageLoadingStateOnChange?(false)
        }
    }
    
    func preloadPetImageData() {
        guard let photoURL = pet.photoURL else { return }
        
        task = imageLoader.loadImageData(from: photoURL) { _ in }
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
    
    var genderText: String {
        return pet.gender == "M" ? "♂" : "♀"
    }
    
    var kindText: String {
        return pet.kind
    }
    
    var cityText: String {
        return String(pet.address[...2])
    }
}
