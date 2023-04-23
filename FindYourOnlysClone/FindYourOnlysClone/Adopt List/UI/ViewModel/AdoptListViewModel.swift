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
    
    private var currentPage = 0
    
    var isPetRefreshLoadingStateOnChange: Observer<Bool>?
    var isPetPaginationLoadingStateOnChange: Observer<Bool>?
    var isPetsAppendingStateOnChange: Observer<[Pet]>?
    var isPetsRefreshingStateOnChange: Observer<[Pet]>?
    
    func refreshPets() {
        currentPage = 0
        loadPets()
    }
    
    func loadNextPage() {
        currentPage += 1
        loadPets()
    }
    
    private func loadPets() {
        currentPage == 0
            ? isPetRefreshLoadingStateOnChange?(true)
            : isPetPaginationLoadingStateOnChange?(true)
        
        petLoader.load(with: AdoptListRequest(page: currentPage)) { [weak self] result in
            if let pets = try? result.get() {
                if self?.currentPage == 0 {
                    self?.isPetsRefreshingStateOnChange?(pets)
                } else {
                    self?.isPetsAppendingStateOnChange?(pets)
                }
            }
            self?.currentPage == 0
                ? self?.isPetRefreshLoadingStateOnChange?(false)
                : self?.isPetPaginationLoadingStateOnChange?(false)
        }
    }
}
