//
//  IconTextField.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import Foundation
import UIKit


final class IconTextField: UIView {
    
    let imageView = UIImageView()
    let textField = UITextField()
    
    var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    var text: String? { textField.text }
    var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    
    init(icon: UIImage?) {
        super.init(frame: .zero)
        layer.cornerRadius = 12
        backgroundColor = UIColor(white: 0.98, alpha: 1)
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray4.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = icon
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .systemFont(ofSize: 15)
        
        addSubview(imageView)
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
}


