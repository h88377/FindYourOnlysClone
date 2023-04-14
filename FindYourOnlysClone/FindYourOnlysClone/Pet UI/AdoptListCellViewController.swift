//
//  AdoptListCellViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

class AdoptListCellViewController {
    private let id = UUID()
    private lazy var cell = AdoptListCell()
    private let viewModel: AdoptListCellViewModel<UIImage>
    
    init(viewModel: AdoptListCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view() -> AdoptListCell {
        cell.genderLabel.text = viewModel.genderText
        cell.cityLabel.text = viewModel.cityText
        cell.kindLabel.text = viewModel.kindText
        cell.retryImageLoadHandler = viewModel.loadPetImageData
        
        viewModel.isPetImageLoadingStateOnChange = { [weak cell] isLoading in
            cell?.petImageContainer.isShimmering = isLoading
        }
        
        viewModel.isPetImageRetryStateOnChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        viewModel.isPetImageStateOnChange = { [weak cell] image in
            cell?.petImageView.image = image
        }
        
        return cell
    }
    
    func requestPetImageData() {
        viewModel.loadPetImageData()
    }
    
    func cancelTask() {
        viewModel.cancelTask()
    }
    
}

extension AdoptListCellViewController: Hashable {
    static func == (lhs: AdoptListCellViewController, rhs: AdoptListCellViewController) -> Bool {
      lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
}
