//
//  CartVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//


import UIKit

class CartVC: UIViewController {

    // MARK: - Data Source
    // Always pull fresh data from CartManager
    private var items: [CartLineItem] {
        return CartManager.shared.items
    }

    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let bottomCard = UIView()
    private let productsTotalLabel = UILabel()
    private let deliveryLabel = UILabel()
    private let grandTotalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)
    private let emptyStateView = UIView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        title = "Savat"

        setupTable()
        setupBottomCard()
        setupEmptyState()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadCart),
            name: .cartUpdated,
            object: nil
        )

        reloadCart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadCart()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table Setup
    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self

        // Register your cell type (make sure CartItemCell exists in the project)
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Bottom Summary Card
    private func setupBottomCard() {
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.backgroundColor = .white
        bottomCard.layer.cornerRadius = 16
        bottomCard.layer.masksToBounds = true

        view.addSubview(bottomCard)

        let labels = [productsTotalLabel, deliveryLabel, grandTotalLabel]
        labels.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomCard.addSubview($0)
        }

        checkoutButton.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.setTitle("Buyurtma berish", for: .normal)
        checkoutButton.backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        checkoutButton.layer.cornerRadius = 28
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        bottomCard.addSubview(checkoutButton)

        NSLayoutConstraint.activate([
            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomCard.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomCard.heightAnchor.constraint(equalToConstant: 170),

            productsTotalLabel.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 18),
            productsTotalLabel.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),

            deliveryLabel.topAnchor.constraint(equalTo: productsTotalLabel.bottomAnchor, constant: 8),
            deliveryLabel.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),

            grandTotalLabel.topAnchor.constraint(equalTo: deliveryLabel.bottomAnchor, constant: 12),
            grandTotalLabel.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),
            grandTotalLabel.bottomAnchor.constraint(equalTo: checkoutButton.topAnchor, constant: -5),

            checkoutButton.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -16),
            checkoutButton.bottomAnchor.constraint(equalTo: bottomCard.bottomAnchor, constant: -16),
            checkoutButton.heightAnchor.constraint(equalToConstant: 56),
        ])

        // Finish table constraints
        tableView.bottomAnchor.constraint(equalTo: bottomCard.topAnchor, constant: -12).isActive = true
    }

    // MARK: - Empty State
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let icon = UIImageView(image: UIImage(named: "cartEmpty"))
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        let exploreButton = UIButton(type: .system)

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        titleLabel.text = "Savat bo'sh"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "Sevimli tortingizni menyudan qo'shing"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        exploreButton.setTitle("Menyuga o'tish", for: .normal)
        exploreButton.backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        exploreButton.setTitleColor(.white, for: .normal)
        exploreButton.layer.cornerRadius = 26
        exploreButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        exploreButton.translatesAutoresizingMaskIntoConstraints = false
        exploreButton.addTarget(self, action: #selector(goToMenu), for: .touchUpInside)

        emptyStateView.addSubview(icon)
        emptyStateView.addSubview(titleLabel)
        emptyStateView.addSubview(subtitleLabel)
        emptyStateView.addSubview(exploreButton)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            icon.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 80),
            icon.widthAnchor.constraint(equalToConstant: 120),
            icon.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -24),

            exploreButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            exploreButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            exploreButton.widthAnchor.constraint(equalTo: emptyStateView.widthAnchor, multiplier: 0.5),
            exploreButton.heightAnchor.constraint(equalToConstant: 52),
        ])
    }

    // MARK: - Refresh Cart
    @objc private func reloadCart() {
        let hasItems = !items.isEmpty

        emptyStateView.isHidden = hasItems
        tableView.isHidden = !hasItems
        bottomCard.isHidden = !hasItems

        tableView.reloadData()
        updateTotals()
        updateTabBarBadge()
    }

    // MARK: - Totals
    private func updateTotals() {
        productsTotalLabel.text = "Mahsulotlar    \(format(CartManager.shared.subtotal))"
        deliveryLabel.text = "Yetkazib berish    \(format(CartManager.shared.deliveryCost))"
        grandTotalLabel.text = "Jami    \(format(CartManager.shared.total))"
    }

    private func updateTabBarBadge() {
        guard let items = tabBarController?.tabBar.items, items.count > 3 else { return }

        let cartItem = items[3]
        let count = CartManager.shared.items.reduce(0) { $0 + $1.quantity }

        cartItem.badgeValue = count == 0 ? nil : "\(count)"
        cartItem.badgeColor = .systemPink
    }

    // MARK: - Actions
    @objc private func checkoutTapped() {
        let checkoutVC = CheckoutVC()
        navigationController?.pushViewController(checkoutVC, animated: true)
    }

    @objc private func goToMenu() {
        tabBarController?.selectedIndex = 0
    }

    private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        return (f.string(from: NSNumber(value: value)) ?? "0") + " so'm"
    }
}

// MARK: - Table View
extension CartVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartItemCell.identifier,
            for: indexPath
        ) as? CartItemCell else {
            return UITableViewCell()
        }

        let line = items[indexPath.row]
        cell.configure(with: line)

        // When quantity changes in the cell, update CartManager with cake + serving
        cell.onQuantityChanged = { [weak self] qty in
            CartManager.shared.setQuantity(
                for: line.cake,
                serving: line.serving,
                quantity: qty
            )
            // reload UI after change
            self?.reloadCart()
        }

        // Delete via button in cell
        cell.onDelete = { [weak self] in
            CartManager.shared.remove(line)
            self?.reloadCart()
        }

        return cell
    }

    // Swipe delete
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath:
        IndexPath
    ) -> UISwipeActionsConfiguration? {

        let line = items[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "O'chirish") { [weak self] _, _, done in
            CartManager.shared.remove(line)
            self?.reloadCart()
            done(true)
        }

        delete.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 110
    }
}
