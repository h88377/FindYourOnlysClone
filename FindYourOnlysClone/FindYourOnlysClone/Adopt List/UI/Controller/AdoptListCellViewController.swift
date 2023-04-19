//
//  AdoptListCellViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

final class AdoptListCellViewController {
    private let id = UUID()
    private var cell: AdoptListCell?
    private let viewModel: AdoptListCellViewModel<UIImage>
    
    init(viewModel: AdoptListCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func view(in collectionView: UICollectionView, at indexPath: IndexPath) -> AdoptListCell {
        cell = collectionView.dequeueReusableCell(for: indexPath)
        
        cell?.genderLabel.text = viewModel.genderText
        cell?.cityLabel.text = viewModel.cityText
        cell?.kindLabel.text = viewModel.kindText
        cell?.retryButton.isHidden = true
        cell?.retryImageLoadHandler = viewModel.loadPetImageData
        
        viewModel.isPetImageLoadingStateOnChange = { [weak cell] isLoading in
            cell?.petImageContainer.isShimmering = isLoading
        }
        
        viewModel.isPetImageRetryStateOnChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        viewModel.isPetImageStateOnChange = { [weak cell] image in
            cell?.petImageView.image = image
        }
        
        return cell!
    }
    
    func requestPetImageData() {
        viewModel.loadPetImageData()
    }
    
    func cancelTask() {
        viewModel.cancelTask()
        releaseCallBacksForCellReuse()
    }
    
    private func releaseCallBacksForCellReuse() {
        viewModel.isPetImageStateOnChange = nil
        viewModel.isPetImageRetryStateOnChange = nil
        viewModel.isPetImageLoadingStateOnChange = nil
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
