//
//  CheckoutCardView.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import Foundation

import UIKit

final class CheckoutCardView: UIView {
    private let titleLabel = UILabel()
    private let headerRightContainer = UIView()
    private let container = UIView()
    
    init(title: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 16
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 8
        
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerRightContainer.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(headerRightContainer)
        addSubview(container)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            
            headerRightContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            headerRightContainer.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            container.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
    
    func setContent(view: UIView) {
        container.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
    }
    
    func setHeaderAccessory(view: UIView) {
        headerRightContainer.subviews.forEach { $0.removeFromSuperview() }
        view.translatesAutoresizingMaskIntoConstraints = false
        headerRightContainer.addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: headerRightContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: headerRightContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: headerRightContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: headerRightContainer.trailingAnchor)
        ])
    }
}
