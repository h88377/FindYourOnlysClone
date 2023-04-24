//
//  AdoptListPaginationViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/24.
//

import UIKit

final class AdoptListPaginationViewController {
    private let viewModel: AdoptListPaginationViewModel
    
    init(viewModel: AdoptListPaginationViewModel) {
        self.viewModel = viewModel
        self.setUpBinding()
    }
    
    private(set) var isPaginating = false
    
    func resetPage() {
        viewModel.resetPage()
    }
     
    func paginate(on scrollView: UIScrollView) {
        guard !isPaginating else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > (contentHeight - frameHeight) {
            viewModel.loadNextPage()
        }
    }
    
    private func setUpBinding() {
        viewModel.isPetPaginationLoadingStateOnChange = { [weak self] isPaginating in
            self?.isPaginating = isPaginating
        }
    }
}
