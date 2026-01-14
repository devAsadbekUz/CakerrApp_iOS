
//  HomeViewController.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//


import UIKit

// MARK: - Section Types
enum HomeSection: Int {
    case banner = 0

    static func productSection(for categoryIndex: Int) -> Int {
        return 1 + categoryIndex
    }

    static func categoryIndex(from section: Int) -> Int {
        return section - 1
    }
}


// MARK: - Home View Controller
class HomeVC: UIViewController {

    // MARK: - UI
    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar!
    private var headerView: UIView!
    private var categoriesView: CategoryHeaderView!

    // MARK: - Data
    private var bannerItems: [BannerItem] = []
    private var categories: [CategoryItem] = []
    private var cakes: [CakeItem] = []
    private var cakesByCategory: [[CakeItem]] = []

    private var selectedCategoryIndex: Int = 0
    private var currentBannerIndex: Int = 0
    private var bannerTimer: Timer?

    private var isScrollingProgrammatically = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(likesChanged),
            name: .likesUpdated,
            object: nil
        )
        
        
        view.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)

        loadMockData()
        setupHeaderView()
        setupCategoriesView()
        setupCollectionView()
        startBannerAutoScroll()
        navigationController?.setNavigationBarHidden(true, animated: false)

    }
    


    deinit { bannerTimer?.invalidate() }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Header Setup
    private func setupHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = .white
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let titleLabel = UILabel()
        titleLabel.text = "Tortlarni kashf eting"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let contactButton = UIButton(type: .custom)
        contactButton.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.9, alpha: 1)
        contactButton.layer.cornerRadius = 22
        
        let icon = UIImage(named: "headphones")
        let resized = icon?.withRenderingMode(.alwaysOriginal).resized(to: CGSize(width: 22, height: 22))

        
        contactButton.setImage(resized, for: .normal)
        contactButton.translatesAutoresizingMaskIntoConstraints = false
        contactButton.addTarget(self, action: #selector(contactTapped), for: .touchUpInside)
        searchBar = UISearchBar()
        searchBar.placeholder = "Tortlarni qidiring..."
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        searchBar.layer.cornerRadius = 24
        searchBar.clipsToBounds = true
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(titleLabel)
        headerView.addSubview(contactButton)
        headerView.addSubview(searchBar)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),

            contactButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            contactButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            contactButton.widthAnchor.constraint(equalToConstant: 44),
            contactButton.heightAnchor.constraint(equalToConstant: 44),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    // MARK: - Sticky Categories Header
    private func setupCategoriesView() {
        categoriesView = CategoryHeaderView()
        categoriesView.backgroundColor = .white
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        categoriesView.configure(with: categories, selectedIndex: selectedCategoryIndex)
        categoriesView.delegate = self
        view.addSubview(categoriesView)

        NSLayoutConstraint.activate([
            categoriesView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            categoriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoriesView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }

    // MARK: - Collection
    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        // Register cells (make sure BannerCell.swift exists)
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.identifier)
        collectionView.register(CakeCell.self, forCellWithReuseIdentifier: CakeCell.identifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoriesView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Layout
    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            return sectionIndex == 0 ? self.bannerSection(environment: environment) : self.productSection()
        }
    }

    
    
    private func bannerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(150)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)


        return section
    }

   

    private func productSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .estimated(260))
        )
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(260)),
            subitems: [item]
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)

        return section
    }

    // MARK: - MOCK DATA (FULL)
    private func loadMockData() {

        bannerItems = MockData.shared.bannerItems
        categories = MockData.shared.categories
        cakes = MockData.shared.allCakes
        cakesByCategory = MockData.shared.cakesByCategory
    }

    private func groupCakesByCategory() {
        cakesByCategory = categories.map { category in
            cakes.filter { $0.category == category.name }
        }
    }

    // MARK: - Banner Auto Scroll
    private func startBannerAutoScroll() {
        bannerTimer?.invalidate()
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.scrollToNextBanner()
        }
    }

    private func scrollToNextBanner() {
        guard bannerItems.count > 1 else { return }

        currentBannerIndex = (currentBannerIndex + 1) % bannerItems.count
        let indexPath = IndexPath(item: currentBannerIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    // MARK: - Scroll Sync Logic (Safe)
    private func updateVisibleCategory() {
        guard !isScrollingProgrammatically else { return }

        let totalSections = collectionView.numberOfSections
        guard totalSections > 1 else { return }

        let topY = collectionView.contentOffset.y + headerView.frame.height + categoriesView.frame.height

        var closestSection: Int?
        var smallestDistance: CGFloat = .greatestFiniteMagnitude

        for section in 1 ..< totalSections {
            let indexPath = IndexPath(item: 0, section: section)

            if let attrs = collectionView.layoutAttributesForSupplementaryElement(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            ) {
                let distance = abs(attrs.frame.origin.y - topY)
                if distance < smallestDistance {
                    smallestDistance = distance
                    closestSection = section
                }
            }
        }

        guard let found = closestSection else { return }

        let categoryIndex = HomeSection.categoryIndex(from: found)
        if categoryIndex != selectedCategoryIndex {
            selectedCategoryIndex = categoryIndex
            categoriesView.selectCategory(at: categoryIndex)
        }
    }

    private func scrollToCategory(_ index: Int) {
        isScrollingProgrammatically = true

        let section = HomeSection.productSection(for: index)
        let indexPath = IndexPath(item: 0, section: section)

        if let attrs = collectionView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        ) {
            let y = attrs.frame.origin.y - headerView.frame.height - categoriesView.frame.height - 6
            collectionView.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.isScrollingProgrammatically = false
        }
    }

    // MARK: - Actions
    
    
    
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

    
    @objc private func likesChanged() {
        collectionView.reloadData()
    }
    

    @objc private func contactTapped() {
        let vc = ContactSheetVC()
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 25
            
            
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}

// MARK: - DATA SOURCE
extension HomeVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 + categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? bannerItems.count : cakesByCategory[HomeSection.categoryIndex(from: section)].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.identifier, for: indexPath) as! BannerCell
            let item = bannerItems[indexPath.item]
            cell.configure(with: item)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CakeCell.identifier, for: indexPath) as! CakeCell
        let categoryIndex = HomeSection.categoryIndex(from: indexPath.section)
        cell.configure(with: cakesByCategory[categoryIndex][indexPath.item])
        cell.delegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionView.elementKindSectionHeader, indexPath.section >= 1 {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView

            let categoryIndex = HomeSection.categoryIndex(from: indexPath.section)
            header.configure(title: categories[categoryIndex].name, count: cakesByCategory[categoryIndex].count)
            return header
        }

        return UICollectionReusableView()
    }
}

// MARK: - SCROLL DELEGATE
extension HomeVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateVisibleCategory()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ignore banner section
        if indexPath.section == 0 { return }
        
        let categoryIndex = HomeSection.categoryIndex(from: indexPath.section)
        let cake = cakesByCategory[categoryIndex][indexPath.item]
        
        // MARK: Recent change
        let detailVC = CakeDetailVC(cake: cake)
        navigationController?.pushViewController(detailVC, animated: true)
        
        
    }
    

    
}

// MARK: - CATEGORY TAP DELEGATE
extension HomeVC: CategoryHeaderViewDelegate {
    func categoryHeaderView(_ view: CategoryHeaderView, didSelectCategoryAt index: Int) {
        selectedCategoryIndex = index
        categoriesView.selectCategory(at: index)
        scrollToCategory(index)
    }
}

// MARK: - SEARCH BAR
extension HomeVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            groupCakesByCategory()
        } else {
            let filtered = cakes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            cakesByCategory = categories.map { category in
                filtered.filter { $0.category == category.name }
            }
        }

        let total = collectionView.numberOfSections
        if total > 1 {
            collectionView.reloadSections(IndexSet(1 ..< total))
        }
    }
}

// MARK: - CAKE CELL DELEGATE
extension HomeVC: CakeCellDelegate {

    func cakeCellDidTapLike(_ cell: CakeCell, button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let categoryIndex = HomeSection.categoryIndex(from: indexPath.section)
        let cake = cakesByCategory[categoryIndex][indexPath.item]

        LikeManager.shared.toggleLike(cake)
        collectionView.reloadItems(at: [indexPath])
    }

    func cakeCellDidTapAddToCart(_ cell: CakeCell, button: UIButton) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let categoryIndex = HomeSection.categoryIndex(from: indexPath.section)
        let cake = cakesByCategory[categoryIndex][indexPath.item]

        AddToCartHelper.addToCart(
            from: self,
            cake: cake,
            selectedServing: nil,
            quantity: 1,
            sourceView: button
        )
    }
}
