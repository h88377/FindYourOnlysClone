//
//  UIView+Extension.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/14.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
    
    var isShowingActivityIndicator: Bool {
        set {
            if newValue {
                startLoading()
            } else {
                stopLoading()
            }
        }

        get {
            return subviews.last is UIActivityIndicatorView
        }
    }

    private func startLoading() {
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        loadingIndicator.startAnimating()
    }

    private func stopLoading() {
        (subviews.last as? UIActivityIndicatorView)?.stopAnimating()
        subviews.last?.removeFromSuperview()
    }

}
