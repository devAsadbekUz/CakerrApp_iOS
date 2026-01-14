//
//  LikedVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import UIKit

class LikedVC: UIViewController,
               UICollectionViewDelegate,
               UICollectionViewDataSource,
               UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private let emptyStateView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Sevimlilar"

        setupCollectionView()
        setupEmptyState()
        updateEmptyStateVisibility()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadLiked),
            name: .likesUpdated,
            object: nil
        )
    }

    @objc private func reloadLiked() {
        collectionView.reloadData()
        updateEmptyStateVisibility()
    }

    // MARK: - Empty State Logic
    private func updateEmptyStateVisibility() {
        let hasLikes = !LikeManager.shared.likedCakes.isEmpty
        emptyStateView.isHidden = hasLikes
        collectionView.isHidden = !hasLikes
    }

    // MARK: - Setup CollectionView
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CakeCell.self, forCellWithReuseIdentifier: "CakeCell")

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    // MARK: Animation
    func animateAddToCart(from cell: CakeCell, cake: CakeItem) {

        guard
            let window = view.window,
            let cellFrame = cell.superview?.convert(cell.frame, to: window),
            let tabBar = self.tabBarController?.tabBar
        else { return }

        // Find the cart tab frame
        guard let cartItemView = tabBar.subviews[safe: 4] ?? tabBar.subviews.last else { return }

        let cartFrame = cartItemView.superview!.convert(cartItemView.frame, to: window)

        // Create flying image
        let imageView = UIImageView(image: UIImage(named: cake.images.first ?? ""))
        imageView.frame = CGRect(
            x: cellFrame.midX - 30,
            y: cellFrame.minY + 10,
            width: 60,
            height: 60
        )
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true

        window.addSubview(imageView)

        // Animate to cart
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            imageView.frame = CGRect(
                x: cartFrame.midX - 5,
                y: cartFrame.midY - 5,
                width: 10,
                height: 10
            )
            imageView.alpha = 0.3
        }, completion: { _ in
            imageView.removeFromSuperview()
        })
    }


    // MARK: - Empty State UI
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)

        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ICON
        let icon = UIImageView(image: UIImage(named: "noLikesYet"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        // TITLE
        let titleLabel = UILabel()
        titleLabel.text = "Sizda hali sevimli tort yo'q"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .darkText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // SUBTITLE
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Menyuga o'tib o'zingiz sevgan tortlarni yurak tugmachasi orqali belgilang"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView.addSubview(icon)
        emptyStateView.addSubview(titleLabel)
        emptyStateView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            icon.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 80),
            icon.widthAnchor.constraint(equalToConstant: 96),
            icon.heightAnchor.constraint(equalToConstant: 96),

            titleLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        // BUTTON (NEW)
        let exploreButton = UIButton(type: .system)
        exploreButton.setTitle("Menyuga o'tish", for: .normal)
        exploreButton.setTitleColor(.white, for: .normal)
        exploreButton.backgroundColor = .systemPink
        exploreButton.layer.cornerRadius = 26
        exploreButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        exploreButton.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView.addSubview(exploreButton)

        NSLayoutConstraint.activate([
            exploreButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            exploreButton.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            exploreButton.widthAnchor.constraint(equalTo: emptyStateView.widthAnchor, multiplier: 0.4),
            exploreButton.heightAnchor.constraint(equalToConstant: 60),
            exploreButton.bottomAnchor.constraint(lessThanOrEqualTo: emptyStateView.bottomAnchor)
        ])

        // Go to home tab
        exploreButton.addAction(UIAction(handler: { _ in
            self.tabBarController?.selectedIndex = 0
        }), for: .touchUpInside)
    }

    // MARK: - CollectionView Data
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LikeManager.shared.likedCakes.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CakeCell",
            for: indexPath
        ) as! CakeCell

        let cake = LikeManager.shared.likedCakes[indexPath.item]
        cell.configure(with: cake)
        cell.delegate = self
        return cell
    }

    // MARK: - Tap → Go to Detail
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cake = LikeManager.shared.likedCakes[indexPath.item]
        let detailVC = CakeDetailVC(cake: cake)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - Cell size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (view.frame.width - 16 - 16 - 12) / 2
        return CGSize(width: width, height: width * 1.45)
    }
}

// MARK: - Cell Delegate
    
extension LikedVC: CakeCellDelegate {

    func cakeCellDidTapLike(_ cell: CakeCell, button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let cake = LikeManager.shared.likedCakes[indexPath.item]
        LikeManager.shared.toggleLike(cake)

        reloadLiked()
    }

    func cakeCellDidTapAddToCart(_ cell: CakeCell, button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let cake = LikeManager.shared.likedCakes[indexPath.item]

        AddToCartHelper.addToCart(
            from: self,
            cake: cake,
            selectedServing: nil,
            quantity: 1,
            sourceView: button
        )
    }
}
