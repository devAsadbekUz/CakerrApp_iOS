//
//  ContactSheetVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation


import UIKit

class ContactSheetVC: UIViewController {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupItems()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        
        // Title
        titleLabel.text = "Biz bilan bog'laning"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Savollaringiz bormi? Biz bilan quyidagi usullar orqali bog'laning"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    private func setupItems() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        // PHONE ITEM
        stack.addArrangedSubview(makeItem(
            icon: "phone.fill",
            iconColor: .systemGreen,
            title: "Telefon",
            subtitle: "+998 90 123 45 67",
            action: #selector(callTapped)
        ))
        
        // TELEGRAM ITEM
        stack.addArrangedSubview(makeItem(
            icon: "paperplane.fill",
            iconColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),
            title: "Telegram",
            subtitle: "buvaydamoida",
            action: #selector(telegramTapped)
        ))
        
        // INSTAGRAM ITEM
        stack.addArrangedSubview(makeItem(
            icon: "camera.fill",
            iconColor: UIColor.systemPink,
            title: "Instagram",
            subtitle: "@cakeorders.uz",
            action: #selector(instagramTapped)
        ))
    }
    
    private func makeItem(icon: String, iconColor: UIColor, title: String, subtitle: String, action: Selector) -> UIView {
        
        let container = UIButton(type: .system)
        container.backgroundColor = UIColor(white: 0.95, alpha: 1)
        container.layer.cornerRadius = 18
        container.heightAnchor.constraint(equalToConstant: 70).isActive = true
        container.addTarget(self, action: action, for: .touchUpInside)
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(iconView)
        container.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    
    // MARK: - ACTION HANDLERS
    
    @objc private func callTapped() {
        if let url = URL(string: "tel://+998918554002") {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func telegramTapped() {
        let username = "buvaydamoida"
        
        // TG App link
        if let appURL = URL(string: "tg://resolve?domain=\(username)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }
        
        // Browser fallback
        if let webURL = URL(string: "https://t.me/\(username)") {
            UIApplication.shared.open(webURL)
        }
    }
    
    @objc private func instagramTapped() {
        let username = "moida_cooking_house"
        
        // Instagram app deep link
        if let appURL = URL(string: "instagram://user?username=\(username)"),
           UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
            return
        }
        
        // Browser fallback
        if let webURL = URL(string: "https://instagram.com/\(username)") {
            UIApplication.shared.open(webURL)
        }
    }
}
