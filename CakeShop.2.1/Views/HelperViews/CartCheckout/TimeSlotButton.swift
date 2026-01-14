//
//  TimeSlotButton.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import Foundation
import UIKit


final class TimeSlotButton: UIButton {
    let titleText: String
    init(title: String) {
        self.titleText = title
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.label, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
                setTitleColor(.white, for: .normal)
                layer.borderColor = UIColor.clear.cgColor
            } else {
                backgroundColor = .clear
                setTitleColor(.label, for: .normal)
                layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
}
