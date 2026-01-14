//
//  BannerCell.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation
import UIKit

import UIKit

class BannerCell: UICollectionViewCell {
    
    static let identifier = "BannerCell"
    
    private let bgView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bgView.bounds
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        // Card view
        bgView.layer.cornerRadius = 20
        bgView.clipsToBounds = true
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.12
        bgView.layer.shadowOffset = CGSize(width: 0, height: 6)
        bgView.layer.shadowRadius = 12
        bgView.backgroundColor = .secondarySystemBackground
        bgView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bgView)
        
        // Background gradient
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.1).cgColor,
            UIColor.black.withAlphaComponent(0.35).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
        bgView.layer.addSublayer(gradientLayer)
        
        // IMAGE
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // TITLE
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // SUBTITLE
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.numberOfLines = 1
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(imageView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.topAnchor.constraint(equalTo: bgView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -48),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
    }
    
    
    func configure(with item: BannerItem) {
        bgView.backgroundColor = item.backgroundColor
        imageView.image = UIImage(named: item.image)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
    }
}
