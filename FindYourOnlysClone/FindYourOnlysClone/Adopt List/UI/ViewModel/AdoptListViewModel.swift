//
//  AdoptListViewModel.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import Foundation

final class AdoptListViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private var petLoader: PetLoader
    
    init(petLoader: PetLoader) {
        self.petLoader = petLoader
    }
    
    var isPetRefreshLoadingStateOnChange: Observer<Bool>?
    var isPetsRefreshingStateOnChange: Observer<[Pet]>?
    
    func refreshPets() {
        loadPets()
    }
    
    private func loadPets() {
        isPetRefreshLoadingStateOnChange?(true)
        
        petLoader.load(with: AdoptListRequest(page: 0)) { [weak self] result in
            if let pets = try? result.get() {
                self?.isPetsRefreshingStateOnChange?(pets)
            }
            self?.isPetRefreshLoadingStateOnChange?(false)
        }
    }
}
