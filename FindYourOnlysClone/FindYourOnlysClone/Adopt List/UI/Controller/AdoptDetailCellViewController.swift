//
//  AdoptDetailCellViewController.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/5/2.
//

import UIKit

final class AdoptDetailCellViewController {
    private let id = UUID()
    private let viewModel: AdoptDetailCellViewModel
    
    init(viewModel: AdoptDetailCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view(in collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell? {
        switch viewModel.detailSection {
        case is StatusSection:
            let cell: AdoptDetailStatusCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.statusLabel.text = viewModel.descriptionText
            return cell
            
        case is MainInfoSection:
            let cell: AdoptDetailMainInfoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.infoTitleLabel.text = viewModel.titleText
            cell.infoLabel.text = viewModel.descriptionText
            return cell
            
        case is SubInfoSection:
            let cell: AdoptDetailInfoCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.infoTitleLabel.text = viewModel.titleText
            cell.infoLabel.text = viewModel.descriptionText
            return cell
            
        default: return nil
        }
    }
    
    func append(in snapshot: inout NSDiffableDataSourceSnapshot<AdoptDetailSection, AdoptDetailCellViewController>) {
        switch viewModel.detailSection {
        case is StatusSection:
            snapshot.appendItems([self], toSection: .status)
            
        case is MainInfoSection:
            snapshot.appendItems([self], toSection: .mainInfo)
            
        case is SubInfoSection:
            snapshot.appendItems([self], toSection: .info)
            
        default: break
        }
    }
}

extension AdoptDetailCellViewController: Hashable {
    static func == (lhs: AdoptDetailCellViewController, rhs: AdoptDetailCellViewController) -> Bool {
      lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
}
