//
//  DataFieldView.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import Foundation
import UIKit

final class DateFieldView: UIControl {

    private let container = UIView()
    private let label = UILabel()
    private let iconView = UIImageView(image: UIImage(systemName: "calendar"))
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))

    var onTap: (() -> Void)?

    init(placeholder: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .clear

        container.backgroundColor = UIColor(white: 0.98, alpha: 1)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.systemGray4.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        // IMPORTANT FIX — prevent stealing touches
        container.isUserInteractionEnabled = false
        label.isUserInteractionEnabled = false
        iconView.isUserInteractionEnabled = false
        chevron.isUserInteractionEnabled = false

        label.text = placeholder
        label.font = .systemFont(ofSize: 15)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        iconView.tintColor = .systemGray
        iconView.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = .systemGray
        chevron.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        container.addSubview(iconView)
        container.addSubview(label)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func tapped() {
        print("DateField: tapped() fired")
        onTap?()
    }

    func setText(_ text: String) {
        label.text = text
        label.textColor = .label
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.contains(point) // FIX: ensures hit detection
    }
}
