//
//  SectionHeaderView.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation
import UIKit

// MARK: - Section Header View
class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        countLabel.textColor = .systemGray
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "\(count) tortlar"
    }
}
