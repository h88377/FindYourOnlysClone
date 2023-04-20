//
//  AdoptListCell+TestHelpers.swift
//  FindYourOnlysCloneTests
//
//  Created by 鄭昭韋 on 2023/4/20.
//

import Foundation
@testable import FindYourOnlysClone

extension AdoptListCell {
    func simulateRetryAction() {
        retryButton.simulateTap()
    }
    
    var kindText: String? {
        return kindLabel.text
    }
    
    var genderText: String? {
        return genderLabel.text
    }
    
    var cityText: String? {
        return cityLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return petImageContainer.isShimmering
    }
    
    var isShowingImageRetryAction: Bool {
        return !retryButton.isHidden
    }
    
    var renderedImageData: Data? {
        return petImageView.image?.pngData()
    }
}
