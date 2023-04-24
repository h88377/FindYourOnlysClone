//
//  ErrorView.swift
//  FindYourOnlysClone
//
//  Created by 鄭昭韋 on 2023/4/24.
//

import UIKit

final class ErrorView: UIView {
    let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    var isVisible: Bool {
        return alpha > 0
    }
    
    private var message: String? {
        didSet { messageLabel.text = message }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ message: String?, on view: UIView) {
        guard superview == nil else { return }
        
        self.message = message
        
        view.addSubview(self)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            heightAnchor.constraint(equalTo: widthAnchor)
        ])
        
        UIView.animate(
            withDuration: 1,
            animations: { self.alpha = 1 },
            completion: { isCompleted in
                if isCompleted { self.hide() }
            })
    }
    
    private func hide() {
        UIView.animate(
            withDuration: 1,
            animations: { self.alpha = 0},
            completion: { isCompleted in
                self.message = nil
                self.removeFromSuperview()
            })
    }
    
    private func setUpUI() {
        backgroundColor = .darkGray
        
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
}
