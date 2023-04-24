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
        cell?.genderLabel.textColor = viewModel.genderText == "♂" ? .maleColor : .femaleColor
        cell?.cityLabel.text = viewModel.cityText
        cell?.kindLabel.text = viewModel.kindText
        cell?.retryButton.isHidden = true
        
        cell?.retryImageLoadHandler = viewModel.loadPetImageData
        cell?.prepareForReuseHandler = { [weak self, weak cell] in
            cell?.petImageView.image = nil
            self?.releaseBindings()
        }
        
        return cell!
    }
    
    func requestPetImageData() {
        cell?.petImageView.image = nil
        
        setUpBindings()
        viewModel.loadPetImageData()
    }
    
    func cancelTask() {
        viewModel.cancelTask()
        releaseBindings()
    }
    
    private func setUpBindings() {
        viewModel.isPetImageLoadingStateOnChange = { [weak cell] isLoading in
            cell?.petImageContainer.isShimmering = isLoading
        }
        
        viewModel.isPetImageRetryStateOnChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }
        
        viewModel.isPetImageStateOnChange = { [weak cell] image in
            cell?.petImageView.image = image
        }
    }
    
    private func releaseBindings() {
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

extension UIColor {
    static let maleColor = hexStringToUIColor(hex: "398AB9")
    static let femaleColor = hexStringToUIColor(hex: "ffcb65")
    static let projectIconColor = hexStringToUIColor(hex: "578c93")
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
}
