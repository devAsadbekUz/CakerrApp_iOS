//
//  CakeCell.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation
import UIKit

// MARK: - Cake Cell
protocol CakeCellDelegate: AnyObject {
    func cakeCellDidTapLike(_ cell: CakeCell, button: UIButton)
    func cakeCellDidTapAddToCart(_ cell: CakeCell, button: UIButton)
}

class CakeCell: UICollectionViewCell {
    
    private var cake: CakeItem?

    
    
    static let identifier = "CakeCell"
    weak var delegate: CakeCellDelegate?
    
    private let containerView = UIView()
    private let imageView = UIImageView()
    private let likeButton = UIButton(type: .custom)
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    private let fromLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOpacity = 0.08
        
        // Image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // Like button
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        likeButton.tintColor = .systemPink
        likeButton.backgroundColor = .white
        likeButton.layer.cornerRadius = 18
        likeButton.layer.shadowColor = UIColor.black.cgColor
        likeButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        likeButton.layer.shadowRadius = 4
        likeButton.layer.shadowOpacity = 0.1
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        contentView.addSubview(likeButton)
        
        // Name label
        nameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        // Price label
        priceLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        priceLabel.textColor = .systemPink
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        // Add button
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .systemPink
        addButton.layer.cornerRadius = 18
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
        
        // from 25,000 sum label
        fromLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        fromLabel.textColor = .systemGray
        fromLabel.text = "dan boshlab"
        fromLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fromLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            likeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            likeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 36),
            likeButton.heightAnchor.constraint(equalToConstant: 36),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            fromLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 2),
            fromLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            addButton.centerYAnchor.constraint(equalTo: fromLabel.centerYAnchor, constant: -10),

            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 36),
            addButton.heightAnchor.constraint(equalToConstant: 36),

            fromLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)

        ])
    }
    
    func configure(with cake: CakeItem) {
        
        self.cake = cake    // <-- this is required

        nameLabel.text = cake.name

        // Price
        if let minPrice = cake.pricesByServing.values.min() {
            priceLabel.text = formatPrice(minPrice)
        }

        // Proper like state
        likeButton.isSelected = LikeManager.shared.isLiked(cake)
        

        // Image
        if let first = cake.images.first {
            imageView.image = UIImage(named: first)
        }
    }

    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        if let formatted = formatter.string(from: NSNumber(value: price)) {
            return "\(formatted) so'm"
        }
        return "\(price) so'm"
    }
    
    
    // MARK:  Actions
    @objc private func likeTapped() {
        guard let cake = cake else { return }

        // Update global liked list
        LikeManager.shared.toggleLike(cake)

        // Sync UI state
        likeButton.isSelected = LikeManager.shared.isLiked(cake)

        // Animation
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        animateLikeButton(likeButton)

        // Let HomeVC / LikedVC update their grids
        NotificationCenter.default.post(name: .likesUpdated, object: nil)

        // Inform delegate with the CORRECT BUTTON
        delegate?.cakeCellDidTapLike(self, button: likeButton)
    }

    @objc private func addTapped() {
        // Button tap animation
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.addButton.transform = .identity
            }
        }

        // Inform delegate with the CORRECT BUTTON
        delegate?.cakeCellDidTapAddToCart(self, button: addButton)
    }

    
    private func animateLikeButton(_ button: UIButton) {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.7
        animation.toValue = 1.0
        animation.stiffness = 200
        animation.mass = 1
        animation.duration = animation.settlingDuration
        animation.initialVelocity = 0.5

        button.layer.add(animation, forKey: nil)
    }
}

