//
//  CartItemCell.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 24/11/25.
//

import Foundation


import UIKit

final class CartItemCell: UITableViewCell {

    static let identifier = "CartItemCell"

    var onQuantityChanged: ((Int) -> Void)?
    var onDelete: (() -> Void)?

    private var currentLine: CartLineItem?
    private var quantity: Int = 1

    private let container = UIView()
    private let cakeImage = UIImageView()
    private let nameLabel = UILabel()
    private let detailsLabel = UILabel()
    private let priceLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let qtyLabel = UILabel()
    private let trashButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        contentView.addSubview(container)

        cakeImage.translatesAutoresizingMaskIntoConstraints = false
        cakeImage.layer.cornerRadius = 10
        cakeImage.clipsToBounds = true
        cakeImage.contentMode = .scaleAspectFill
        container.addSubview(cakeImage)

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)

        detailsLabel.font = .systemFont(ofSize: 12)
        detailsLabel.textColor = .darkGray
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(detailsLabel)

        priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(priceLabel)

        minusButton.setTitle("−", for: .normal)
        minusButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        minusButton.layer.cornerRadius = 10
        minusButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        minusButton.translatesAutoresizingMaskIntoConstraints = false
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        container.addSubview(minusButton)

        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        plusButton.layer.cornerRadius = 10
        plusButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        container.addSubview(plusButton)

        qtyLabel.font = .systemFont(ofSize: 15)
        qtyLabel.textAlignment = .center
        qtyLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(qtyLabel)

        trashButton.setImage(UIImage(systemName: "trash"), for: .normal)
        trashButton.tintColor = .darkGray
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        container.addSubview(trashButton)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            cakeImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            cakeImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            cakeImage.widthAnchor.constraint(equalToConstant: 80),
            cakeImage.heightAnchor.constraint(equalToConstant: 80),

            trashButton.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            trashButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            trashButton.widthAnchor.constraint(equalToConstant: 28),
            trashButton.heightAnchor.constraint(equalToConstant: 28),

            nameLabel.leadingAnchor.constraint(equalTo: cakeImage.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trashButton.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),

            detailsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),

            priceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            priceLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 8),

            plusButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            plusButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),

            qtyLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            qtyLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            qtyLabel.widthAnchor.constraint(equalToConstant: 28),

            minusButton.trailingAnchor.constraint(equalTo: qtyLabel.leadingAnchor, constant: -8),
            minusButton.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 34),
            minusButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    func configure(with line: CartLineItem) {
        currentLine = line
        quantity = line.quantity

        nameLabel.text = line.cake.name
        detailsLabel.text = "Porsiya: \(line.serving) kishilik"

        if let first = line.cake.images.first {
            cakeImage.image = UIImage(named: first)
        }

        priceLabel.text = format(line.unitPrice * line.quantity)
        qtyLabel.text = "\(line.quantity)"
    }


    private func format(_ n: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return (f.string(from: NSNumber(value: n)) ?? "0") + " so'm"
    }

    @objc private func minusTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        qtyLabel.text = "\(quantity)"
        onQuantityChanged?(quantity)
    }

    @objc private func plusTapped() {
        quantity += 1
        qtyLabel.text = "\(quantity)"
        onQuantityChanged?(quantity)
    }

    @objc private func deleteTapped() {
        onDelete?()
    }
}
