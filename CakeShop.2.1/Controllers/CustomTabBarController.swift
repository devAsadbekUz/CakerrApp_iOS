//
//  CustomTabBarController.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//


import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    private let centerButton = UIButton()
    private let centerLabel = UILabel()

    // MARK: - Persistent ViewControllers (fixes CartVC bug!)
    private let homeVC = HomeVC()
    private let likedVC = LikedVC()
    private let cartVC = CartVC()
    private let profileVC = ProfileVC()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        observeCart()        // MUST come first
        setupViewControllers()
        setupCenterButton()
        styleTabBar()
    }

    // MARK: - CART BADGE LISTENER
    private func observeCart() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCartBadge),
            name: .cartUpdated,
            object: nil
        )
    }

    @objc private func updateCartBadge() {
        DispatchQueue.main.async {
            guard let cartTab = self.tabBar.items?[3] else { return }
            let quantity = CartManager.shared.items.reduce(0) { $0 + $1.quantity }

            cartTab.badgeColor = .systemPink
            cartTab.badgeValue = quantity == 0 ? nil : "\(quantity)"
        }
    }

    // MARK: - Persistent VC Setup
    private func setupViewControllers() {

        let homeNav = UINavigationController(rootViewController: homeVC)
        let likedNav = UINavigationController(rootViewController: likedVC)
        let cartNav = UINavigationController(rootViewController: cartVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        let placeholderVC = UIViewController()
        placeholderVC.tabBarItem.isEnabled = false

        // Tab Icons
        homeNav.tabBarItem = UITabBarItem(
            title: "Asosiy",
            image: UIImage(named: "home"),
            selectedImage: UIImage(named: "home.fill")
        )

        likedNav.tabBarItem = UITabBarItem(
            title: "Sevimli",
            image: UIImage(named: "heart"),
            selectedImage: UIImage(named: "heart.fill")
        )

        cartNav.tabBarItem = UITabBarItem(
            title: "Savat",
            image: UIImage(named: "cart"),
            selectedImage: UIImage(named: "cart.fill")
        )

        profileNav.tabBarItem = UITabBarItem(
            title: "Profil",
            image: UIImage(named: "person"),
            selectedImage: UIImage(named: "person.fill")
        )

        // FINAL TAB ORDER
        viewControllers = [
            homeNav,
            likedNav,
            placeholderVC,
            cartNav,
            profileNav
        ]
    }

    // MARK: - Floating Center Button
    private func setupCenterButton() {

        let size: CGFloat = 58

        centerButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        centerButton.layer.cornerRadius = size / 2
        centerButton.backgroundColor = UIColor(red: 1.00, green: 0.45, blue: 0.00, alpha: 1.0)

        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        centerButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        centerButton.tintColor = .white

        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.20
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        centerButton.layer.shadowRadius = 10

        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        view.addSubview(centerButton)

        // center label
        centerLabel.text = "Yaratish"
        centerLabel.font = UIFont.systemFont(ofSize: 12)
        centerLabel.textColor = UIColor(hex: "#A7A7A7")
        centerLabel.textAlignment = .center
        centerLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(centerLabel)
    }

    @objc private func centerButtonTapped() {
        let newVC = UIViewController()
        newVC.view.backgroundColor = .white
        let nav = UINavigationController(rootViewController: newVC)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }

    // MARK: - Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Custom height
        var frame = tabBar.frame
        frame.size.height = 88
        frame.origin.y = view.frame.height - 88
        tabBar.frame = frame

        // Floating button
        
        
        centerButton.center = CGPoint(
            x: tabBar.center.x,
            y: tabBar.frame.origin.y + 10
        )

        // Label under floating button
        centerLabel.center = CGPoint(
            x: centerButton.center.x,
            y: centerButton.frame.maxY + 15
        )
    }

    // MARK: - Style
    private func styleTabBar() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = UIColor(hex: "#E91E63")
        tabBar.unselectedItemTintColor = UIColor(hex: "#A7A7A7")

        // subtle divider
        let border = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        border.backgroundColor = .systemGray5
        tabBar.addSubview(border)
    }
}
