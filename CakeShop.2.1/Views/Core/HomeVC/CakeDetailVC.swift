
import UIKit



class CakeDetailVC: UIViewController {

    // MARK: - Model
    private let cake: CakeItem
    
    

    // MARK: - State
    private var selectedServing: Int = 0
    private var quantity: Int = 1

    // MARK: - Layout constants
    private let imageHeight: CGFloat = 360
    private let bottomBarHeight: CGFloat = 100

    // MARK: - Views
    private let scrollView = UIScrollView()
    private let contentView = UIView() // pinned to scrollView.contentLayoutGuide

    // image container so buttons can overlay
    private let imageContainer = UIView()
    private let mainImageView = UIImageView()

    private let backButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let statusContainer = UIView()
    private let statusIcon = UIImageView()
    private let statusLabel = UILabel()

    private let infoBox = UIView()
    private let infoLabel = UILabel()

    private let servingsTitleLabel = UILabel()
    private let servingsScroll = UIScrollView()
    private let servingsStack = UIStackView()

    private let specsStack = UIStackView() // vertical stack for chips sections

    // bottom bar
    private let bottomBar = UIView()
    private let priceTitleLabel = UILabel()
    private let priceValueLabel = UILabel()
    private let stepperContainer = UIView()
    private let minusButton = UIButton(type: .system)
    private let plusButton = UIButton(type: .system)
    private let qtyLabel = UILabel()
    private let addButton = UIButton(type: .system)

    // MARK: - Init
    init(cake: CakeItem) {
        self.cake = cake
        super.init(nibName: nil, bundle: nil)
        selectedServing = cake.servings.first ?? 0
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Prevent automatic scroll insets and remove nav gap
        scrollView.contentInsetAdjustmentBehavior = .never
        navigationController?.setNavigationBarHidden(true, animated: false)

        likeButton.isSelected = LikeManager.shared.isLiked(cake)

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
        setupScrollHierarchy()
        setupImageSection()
        setupTopButtonsOverlay()
        setupTitleAndDescription()
        setupStatusIfNeeded()
        setupInfoBox()
        setupServings()
        setupSpecsSections()   // includes Ichki ta'mlar, Qoplama turi, Ichki qoplama, Bezaklar
        setupSpacerAndAnchor()
        setupBottomBar()

        updatePrice()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Setup Scroll + Content
    private func setupScrollHierarchy() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.translatesAutoresizingMaskIntoConstraints = false

        scrollView.contentInset.bottom = bottomBarHeight

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Use contentLayoutGuide & frameLayoutGuide for correct scrolling
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor), // removes top gap
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),

            // contentView matches scrollView width (important)
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // We'll add subviews into contentView in vertical order.
    }

    // MARK: - Image and overlay area
    private func setupImageSection() {
        // Image container so overlay buttons can be positioned relative to it
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        mainImageView.contentMode = .scaleAspectFill
        mainImageView.clipsToBounds = true
        mainImageView.image = UIImage(named: cake.images.first ?? "")

        contentView.addSubview(imageContainer)
        imageContainer.addSubview(mainImageView)

        NSLayoutConstraint.activate([
            imageContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageContainer.heightAnchor.constraint(equalToConstant: imageHeight),
            

            mainImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            mainImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            mainImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            mainImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor)
        ])
    }

    private func setupTopButtonsOverlay() {
        // Style helpers
        func styleButton(_ b: UIButton) {
            b.translatesAutoresizingMaskIntoConstraints = false
            b.backgroundColor = .white
            b.layer.cornerRadius = 20
            b.tintColor = .black
            b.layer.shadowColor = UIColor.black.cgColor
            b.layer.shadowOpacity = 0.12
            b.layer.shadowRadius = 6
            b.layer.shadowOffset = CGSize(width: 0, height: 2)
        }

        styleButton(backButton)
        styleButton(likeButton)
        styleButton(shareButton)

        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        // LIKE BUTTON — proper image switching
        likeButton.setImage(
            UIImage(systemName: "heart")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )

        likeButton.setImage(
            UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal),
            for: .selected
        )

        // Disable tint so the icon keeps its real color
        likeButton.tintColor = .clear
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)

        imageContainer.addSubview(backButton)
        imageContainer.addSubview(likeButton)
        imageContainer.addSubview(shareButton)

        // Position them inside the imageContainer so they overlay the image
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor, constant: 18),
            backButton.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 60),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            shareButton.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -18),
            shareButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 40),
            shareButton.heightAnchor.constraint(equalToConstant: 40),

            likeButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            likeButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            likeButton.widthAnchor.constraint(equalToConstant: 40),
            likeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - Title & Description
    private func setupTitleAndDescription() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = cake.name
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 2

        subtitleLabel.text = cake.description
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Status chip (optional)
    private func setupStatusIfNeeded() {
        guard let status = cake.status else { return }

        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.backgroundColor = UIColor.systemGreen.withOpacity(0.15)
        statusContainer.layer.cornerRadius = 10

        statusIcon.translatesAutoresizingMaskIntoConstraints = false
        statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
        statusIcon.tintColor = .systemGreen

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.text = status
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .systemGreen

        statusContainer.addSubview(statusIcon)
        statusContainer.addSubview(statusLabel)
        contentView.addSubview(statusContainer)

        NSLayoutConstraint.activate([
            statusContainer.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            statusContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            statusIcon.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusIcon.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 20),
            statusIcon.heightAnchor.constraint(equalToConstant: 20),

            statusLabel.leadingAnchor.constraint(equalTo: statusIcon.trailingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            statusLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 8),
            statusLabel.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Info green box
    private func setupInfoBox() {
        infoBox.translatesAutoresizingMaskIntoConstraints = false
        infoBox.backgroundColor = UIColor.systemGreen.withOpacity(0.12)
        infoBox.layer.cornerRadius = 12

        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = "Bu tayyor tort. Siz faqat porsiya miqdorini tanlaysiz va buyurtma berasiz!"
        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .systemGreen

        contentView.addSubview(infoBox)
        infoBox.addSubview(infoLabel)

        // anchor: if status exists, place below it, else below subtitle
        let topAnchor = (cake.status != nil) ? statusContainer.bottomAnchor : subtitleLabel.bottomAnchor

        NSLayoutConstraint.activate([
            infoBox.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            infoBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            infoLabel.leadingAnchor.constraint(equalTo: infoBox.leadingAnchor, constant: 12),
            infoLabel.trailingAnchor.constraint(equalTo: infoBox.trailingAnchor, constant: -12),
            infoLabel.topAnchor.constraint(equalTo: infoBox.topAnchor, constant: 12),
            infoLabel.bottomAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Servings (horizontal large cards)
    private func setupServings() {
        servingsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        servingsTitleLabel.text = "Porsiyalar (Necha kishiga)"
        servingsTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

        servingsScroll.translatesAutoresizingMaskIntoConstraints = false
        servingsScroll.showsHorizontalScrollIndicator = false

        servingsStack.translatesAutoresizingMaskIntoConstraints = false
        servingsStack.axis = .horizontal
        servingsStack.spacing = 12
        servingsStack.alignment = .center

        contentView.addSubview(servingsTitleLabel)
        contentView.addSubview(servingsScroll)
        servingsScroll.addSubview(servingsStack)

        NSLayoutConstraint.activate([
            servingsTitleLabel.topAnchor.constraint(equalTo: infoBox.bottomAnchor, constant: 20),
            servingsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            servingsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            servingsScroll.topAnchor.constraint(equalTo: servingsTitleLabel.bottomAnchor, constant: 12),
            servingsScroll.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            servingsScroll.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            servingsScroll.heightAnchor.constraint(equalToConstant: 120),

            // stack inside scroll
            servingsStack.leadingAnchor.constraint(equalTo: servingsScroll.leadingAnchor, constant: 20),
            servingsStack.topAnchor.constraint(equalTo: servingsScroll.topAnchor),
            servingsStack.bottomAnchor.constraint(equalTo: servingsScroll.bottomAnchor),
            servingsStack.trailingAnchor.constraint(lessThanOrEqualTo: servingsScroll.trailingAnchor, constant: -20)
        ])

        // Add cards
        for s in cake.servings {
            let card = UIButton(type: .system)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.tag = s
            card.setTitle("\(s)\nkishilik", for: .normal)
            card.titleLabel?.numberOfLines = 2
            card.titleLabel?.textAlignment = .center
            card.layer.cornerRadius = 16
            card.backgroundColor = UIColor.systemGray6
            card.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            card.setTitleColor(.systemBlue, for: .normal)

            NSLayoutConstraint.activate([
                card.widthAnchor.constraint(equalToConstant: 140),
                card.heightAnchor.constraint(equalToConstant: 95)
            ])
            card.addTarget(self, action: #selector(servingTapped(_:)), for: .touchUpInside)
            servingsStack.addArrangedSubview(card)
        }

        highlightSelectedServingAppearance()
    }

    @objc private func servingTapped(_ sender: UIButton) {
        selectedServing = sender.tag
        highlightSelectedServingAppearance()
        updatePrice()
    }

    private func highlightSelectedServingAppearance() {
        for case let btn as UIButton in servingsStack.arrangedSubviews {
            if btn.tag == selectedServing {
                btn.backgroundColor = UIColor.systemPink.withOpacity(0.12)
                btn.layer.borderWidth = 2
                btn.layer.borderColor = UIColor.systemPink.cgColor
                btn.setTitleColor(.systemPink, for: .normal)
            } else {
                btn.backgroundColor = UIColor.systemGray6
                btn.layer.borderWidth = 0
                btn.setTitleColor(.systemBlue, for: .normal)
            }
        }
    }

    // MARK: - Specs / chips
    private func setupSpecsSections() {
        specsStack.axis = .vertical
        specsStack.spacing = 18
        specsStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(specsStack)

        // position under servingsScroll
        NSLayoutConstraint.activate([
            specsStack.topAnchor.constraint(equalTo: servingsScroll.bottomAnchor, constant: 20),
            specsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            specsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        // Helper to build each row with horizontal scroll
        func addRow(title: String, items: [String]?, colorHex: String) {
            guard let items = items, !items.isEmpty else { return }

            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)

            let chipsScroll = UIScrollView()
            chipsScroll.showsHorizontalScrollIndicator = false
            chipsScroll.translatesAutoresizingMaskIntoConstraints = false

            let chipsStack = UIStackView()
            chipsStack.axis = .horizontal
            chipsStack.spacing = 10
            chipsStack.translatesAutoresizingMaskIntoConstraints = false

            let baseColor = UIColor(hex: colorHex)

            for item in items {
                let chip = UIButton(type: .system)
                chip.setTitle(item, for: .normal)
                chip.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                chip.setTitleColor(baseColor.darker(), for: .normal)
                chip.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10) // ~5px padding sides
                chip.backgroundColor = baseColor.withOpacity(0.25)
                chip.layer.cornerRadius = 14
                chip.translatesAutoresizingMaskIntoConstraints = false
                chipsStack.addArrangedSubview(chip)
            }

            chipsScroll.addSubview(chipsStack)

            NSLayoutConstraint.activate([
                chipsScroll.heightAnchor.constraint(equalToConstant: 44),
                chipsStack.leadingAnchor.constraint(equalTo: chipsScroll.leadingAnchor, constant: 0),
                chipsStack.topAnchor.constraint(equalTo: chipsScroll.topAnchor),
                chipsStack.bottomAnchor.constraint(equalTo: chipsScroll.bottomAnchor),
                chipsStack.trailingAnchor.constraint(lessThanOrEqualTo: chipsScroll.trailingAnchor)
            ])

            let vertical = UIStackView(arrangedSubviews: [titleLabel, chipsScroll])
            vertical.axis = .vertical
            vertical.spacing = 8

            specsStack.addArrangedSubview(vertical)
        }

        // Add rows: Ichki ta'mlar (pink), Qoplama turi (blue), Ichki qoplama (green pastel), Bezaklar (orange)
        addRow(title: "Ichki ta'mlar", items: cake.innerFlavors, colorHex: "#F7C6D6")
        addRow(title: "Qoplama turi", items: cake.outerCoating, colorHex: "#DCE9FF")
        // new property innerCoating must exist on CakeItem
        addRow(title: "Ichki qoplama", items: cake.innerCoating, colorHex: "#D6FFE2")
        addRow(title: "Bezaklar", items: cake.toppings, colorHex: "#FFE6D6")
    }

    // MARK: - spacer + bottom anchor
    private func setupSpacerAndAnchor() {
        // Add a spacer so content can scroll above bottomBar
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spacer)

        NSLayoutConstraint.activate([
            // Make spacer below specsStack (or below servings if no specs)
            spacer.topAnchor.constraint(equalTo: specsStack.bottomAnchor, constant: 20),
            spacer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacer.heightAnchor.constraint(equalToConstant: bottomBarHeight + 24),

            // contentView bottom -> spacer bottom (important for scroll)
            spacer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Bottom bar fixed (Polished Version)
    private func setupBottomBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .white
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOpacity = 0.08
        bottomBar.layer.shadowRadius = 10
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -4)

        view.addSubview(bottomBar)

        // Bigger height for premium feel
        let barHeight: CGFloat = 135

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: barHeight)
        ])

        // --- LEFT SIDE ---

        priceTitleLabel.text = "Jami narx"
        priceTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceTitleLabel.textColor = UIColor.systemGray

        priceValueLabel.font = UIFont.boldSystemFont(ofSize: 26)
        priceValueLabel.textColor = .systemPink

        let priceStack = UIStackView(arrangedSubviews: [priceTitleLabel, priceValueLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 6

        // --- STEPPER (Qty control) ---

        stepperContainer.backgroundColor = UIColor.systemGray6
        stepperContainer.layer.cornerRadius = 22
        stepperContainer.translatesAutoresizingMaskIntoConstraints = false

        minusButton.setTitle("–", for: .normal)
        minusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        minusButton.tintColor = .black
        minusButton.addTarget(self, action: #selector(qtyMinus), for: .touchUpInside)

        plusButton.setTitle("+", for: .normal)
        plusButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        plusButton.tintColor = .black
        plusButton.addTarget(self, action: #selector(qtyPlus), for: .touchUpInside)

        qtyLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        qtyLabel.textAlignment = .center

        let stepperStack = UIStackView(arrangedSubviews: [minusButton, qtyLabel, plusButton])
        stepperStack.axis = .horizontal
        stepperStack.spacing = 18
        stepperStack.alignment = .center
        stepperStack.translatesAutoresizingMaskIntoConstraints = false

        stepperContainer.addSubview(stepperStack)

        NSLayoutConstraint.activate([
            stepperContainer.widthAnchor.constraint(equalToConstant: 130),
            stepperContainer.heightAnchor.constraint(equalToConstant: 45),

            stepperStack.centerXAnchor.constraint(equalTo: stepperContainer.centerXAnchor),
            stepperStack.centerYAnchor.constraint(equalTo: stepperContainer.centerYAnchor)
        ])

        // --- ADD BUTTON ---

        addButton.setTitle("Qo'shish", for: .normal)
        addButton.backgroundColor = .systemPink
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        addButton.layer.cornerRadius = 28
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)   // ✅ FIX ADDED HERE


        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 165),
            addButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // --- FINAL HORIZONTAL BAR STACK ---

        let leftSide = UIStackView(arrangedSubviews: [priceStack, stepperContainer])
        leftSide.axis = .vertical
        leftSide.spacing = 14
        leftSide.alignment = .leading

        let barStack = UIStackView(arrangedSubviews: [leftSide, addButton])
        barStack.axis = .horizontal
        barStack.alignment = .center
        barStack.distribution = .equalSpacing
        barStack.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.addSubview(barStack)

        NSLayoutConstraint.activate([
            barStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            barStack.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            barStack.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor)
        ])
    }

    // MARK: - Actions
    
    
    
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
    
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func likeTapped() {
        
        
        
        LikeManager.shared.toggleLike(cake)
        likeButton.isSelected = LikeManager.shared.isLiked(cake)

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        animateLikeButton(likeButton)

        // Confetti animation only if liking
        if likeButton.isSelected {
            showMiniHeartBurst(from: likeButton)
        }
        
    
    }

    @objc private func shareTapped() {
        let ac = UIActivityViewController(activityItems: [cake.name, cake.description], applicationActivities: nil)
        present(ac, animated: true)
    }

    @objc private func qtyMinus() {
        if quantity > 1 { quantity -= 1 }
        qtyLabel.text = "\(quantity)"
        updatePrice()
    }

    @objc private func qtyPlus() {
        quantity += 1
        qtyLabel.text = "\(quantity)"
        updatePrice()
    }

    @objc private func addTapped() {

        
        AddToCartHelper.addToCart(
            from: self,
            cake: cake,
            selectedServing: selectedServing,
            quantity: quantity,
            sourceView: addButton
        )
    }

    // MARK: - Helpers
    private func updatePrice() {
        guard let base = cake.pricesByServing[selectedServing] else {
            priceValueLabel.text = "0 so'm"
            return
        }
        let total = base * quantity
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        priceValueLabel.text = (formatter.string(from: NSNumber(value: total)) ?? "\(total)") + " so'm"
    }
    
    
    private func showMiniHeartBurst(from button: UIButton) {
        let burstCount = 6
        let burstRadius: CGFloat = 40

        for i in 0..<burstCount {
            let angle = CGFloat(i) * (.pi * 2 / CGFloat(burstCount))
            let dx = cos(angle) * burstRadius
            let dy = sin(angle) * burstRadius

            let heart = UIImageView(image: UIImage(systemName: "heart.fill")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal))
            heart.frame = CGRect(x: 0, y: 0, width: 14, height: 14)
            heart.center = CGPoint(x: button.bounds.midX, y: button.bounds.midY)
            heart.alpha = 0
            button.addSubview(heart)

            // Animation
            UIView.animateKeyframes(withDuration: 1, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    heart.alpha = 1
                    heart.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                    heart.center = CGPoint(x: button.bounds.midX + dx, y: button.bounds.midY + dy)
                }
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.35) {
                    heart.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    heart.alpha = 0
                }
            }, completion: { _ in
                heart.removeFromSuperview()
            })
        }
    }


}

extension CakeDetailVC: UIGestureRecognizerDelegate  {
    @objc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    

}



