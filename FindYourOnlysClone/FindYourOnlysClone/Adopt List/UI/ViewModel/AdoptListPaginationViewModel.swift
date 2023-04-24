//
//  AdoptListPaginationViewModel.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/24.
//

import Foundation

final class AdoptListPaginationViewModel {
    typealias Observer<T> = ((T) -> Void)
    
    private let petLoader: PetLoader
    
    init(petLoader: PetLoader) {
        self.petLoader = petLoader
    }
    
    private var currentPage = 0
    var isPetPaginationLoadingStateOnChange: Observer<Bool>?
    var isPetsPaginationStateOnChange: Observer<[Pet]>?
    var isPetsPaginationErrorStateOnChange: Observer<String?>?
    
    private var errorMessage: String {
        return "無法連接至伺服器"
    }
    
    func resetPage() {
        currentPage = 0
    }
    
    func loadNextPage() {
        currentPage += 1
        isPetPaginationLoadingStateOnChange?(true)
        petLoader.load(with: AdoptListRequest(page: currentPage)) { [weak self] result in
            if let pets = try? result.get() {
                self?.isPetsPaginationStateOnChange?(pets)
            } else {
                self?.currentPage -= 1
                self?.isPetsPaginationErrorStateOnChange?(self?.errorMessage)
            }
            self?.isPetPaginationLoadingStateOnChange?(false)
        }
    }
    
}
