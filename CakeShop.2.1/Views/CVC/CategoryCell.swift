//
//  CategoryCell.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation
import UIKit


// MARK: - Category Cell
class CategoryCell: UICollectionViewCell {
    static let identifier = "CategoryCell"
    
    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let selectionRing = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Selection ring
        selectionRing.layer.cornerRadius = 32
        selectionRing.layer.borderWidth = 3
        selectionRing.layer.borderColor = UIColor.systemPink.cgColor
        selectionRing.backgroundColor = UIColor.systemPink.withAlphaComponent(0.1)
        selectionRing.alpha = 0
        selectionRing.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionRing)
        
        // Image container
        imageContainer.layer.cornerRadius = 32
        imageContainer.clipsToBounds = true
        imageContainer.layer.borderWidth = 2
        imageContainer.layer.borderColor = UIColor.systemGray5.cgColor
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageContainer)
        
        // Image
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.addSubview(imageView)
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        nameLabel.textColor = .systemGray
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            selectionRing.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionRing.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionRing.widthAnchor.constraint(equalToConstant: 64),
            selectionRing.heightAnchor.constraint(equalToConstant: 64),
            
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 64),
            imageContainer.heightAnchor.constraint(equalToConstant: 64),
            
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with category: CategoryItem, isSelected: Bool) {
        nameLabel.text = category.name
        imageView.image = UIImage(named: category.image)
        
        if isSelected {
            selectionRing.alpha = 1
            imageContainer.layer.borderColor = UIColor.systemPink.cgColor
            imageContainer.layer.borderWidth = 3
            nameLabel.textColor = .systemPink
            nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        } else {
            selectionRing.alpha = 0
            imageContainer.layer.borderColor = UIColor.systemGray5.cgColor
            imageContainer.layer.borderWidth = 2
            nameLabel.textColor = .systemGray
            nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        }
    }
}


