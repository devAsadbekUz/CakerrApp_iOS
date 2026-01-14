
import UIKit

final class ProfileVC: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let headerView = UIView()
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let phoneLabel = UILabel()
    private let editButton = UIButton(type: .custom)

    private let statsContainer = UIView()
    private let ordersLabel = UILabel()
    private let ordersTitle = UILabel()
    private let coinsLabel = UILabel()
    private let coinsTitle = UILabel()

    // Keys
    private enum Keys {
        static let firstName = "profile_first_name"
        static let lastName  = "profile_last_name"
        static let phone     = "profile_phone"      // currently optional — replace with Firebase Auth later
        static let imageData = "profile_image_data"
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        setupScrollView()
        setupHeader()
        setupStatsCard()
        setupMenuList()

        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfileFromStorage()
    }

    // MARK: - Setup
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.93, green: 0.19, blue: 0.54, alpha: 1) // solid pink
        headerView.heightAnchor.constraint(equalToConstant: 230).isActive = true

        // round only bottom corners
        headerView.layer.cornerRadius = 20
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.clipsToBounds = true

        // profile image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = UIImage(named: "profile") ?? UIImage(systemName: "person.circle")
        profileImageView.layer.cornerRadius = 40
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEdit)))

        // labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Sardor Karimov"
        nameLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textColor = .white

        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.text = "+998 90 123 45 67" // placeholder; replace with auth value later
        phoneLabel.font = .systemFont(ofSize: 16)
        phoneLabel.textColor = UIColor.white.withAlphaComponent(0.9)

        // edit button
        editButton.translatesAutoresizingMaskIntoConstraints = false
        if let img = UIImage(named: "prEditVC") {
            editButton.setImage(img, for: .normal)
        } else {
            editButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        }
        editButton.addTarget(self, action: #selector(openEdit), for: .touchUpInside)

        headerView.addSubview(profileImageView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(phoneLabel)
        headerView.addSubview(editButton)

        // Align centers (profile image center, labels center, edit button center)
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            profileImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -8),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: -4),

            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),

            editButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            editButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 40),
            editButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        contentStack.addArrangedSubview(headerView)
    }

    private func setupStatsCard() {
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.backgroundColor = .white
        statsContainer.layer.cornerRadius = 20
        statsContainer.layer.shadowColor = UIColor.black.cgColor
        statsContainer.layer.shadowOpacity = 0.07
        statsContainer.layer.shadowRadius = 8
        statsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        statsContainer.heightAnchor.constraint(equalToConstant: 95).isActive = true

        // wrapper so we can overlap the header (negative top)
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.heightAnchor.constraint(equalToConstant: 35).isActive = true // this will compress visually; actual card sits with negative top
        contentStack.addArrangedSubview(wrapper)
        wrapper.addSubview(statsContainer)

        NSLayoutConstraint.activate([
            statsContainer.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: -60),
            statsContainer.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -16),
            statsContainer.heightAnchor.constraint(equalToConstant: 95),
            statsContainer.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor)
        ])

        // inner content (orders / coins)
        let inner = UIStackView()
        inner.axis = .horizontal
        inner.distribution = .fillEqually
        inner.translatesAutoresizingMaskIntoConstraints = false

        // left
        ordersLabel.text = "12"
        ordersLabel.font = .boldSystemFont(ofSize: 20)
        ordersLabel.textAlignment = .center
        ordersTitle.text = "Buyurtmalar"
        ordersTitle.font = .systemFont(ofSize: 14)
        ordersTitle.textColor = .darkGray
        ordersTitle.textAlignment = .center

        let leftStack = UIStackView(arrangedSubviews: [ordersLabel, ordersTitle])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        // right
        coinsLabel.text = "420"
        coinsLabel.font = .boldSystemFont(ofSize: 20)
        coinsLabel.textAlignment = .center
        coinsTitle.text = "Coins"
        coinsTitle.font = .systemFont(ofSize: 14)
        coinsTitle.textColor = .darkGray
        coinsTitle.textAlignment = .center

        let rightStack = UIStackView(arrangedSubviews: [coinsLabel, coinsTitle])
        rightStack.axis = .vertical
        rightStack.spacing = 4

        inner.addArrangedSubview(leftStack)
        inner.addArrangedSubview(rightStack)
        statsContainer.addSubview(inner)

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 18),
            inner.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -18),
            inner.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 10),
            inner.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -10)
        ])
    }

    private func setupMenuList() {
        let items: [(String, String)] = [
            ("Buyurtmalar tarixi", "prHistory"),
            ("Yetkazib berish manzili", "prLocation"),
            ("Ilovani ulashish", "prShare"),
            ("Sozlamalar", "prSettings"),
            ("Ilovani baholang", "prRate"),
            ("Chiqish", "prExit")
        ]

        for (title, iconName) in items {
            let row = makeMenuRow(title: title, iconName: iconName)
            contentStack.addArrangedSubview(row)

            // spacing from content edges
            row.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 16).isActive = true
            row.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -16).isActive = true
        }
    }

    private func makeMenuRow(title: String, iconName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 18
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 80).isActive = true

        let icon = UIImageView(image: UIImage(named: iconName))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 17)

        let subtitleLabel = UILabel()
        subtitleLabel.text = rowSubtitle(for: title)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .darkGray

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .systemGray2
        arrow.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(icon)
        container.addSubview(textStack)
        container.addSubview(arrow)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),

            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(menuTapped(_:)))
        container.addGestureRecognizer(tap)
        container.accessibilityLabel = title

        return container
    }

    private func rowSubtitle(for title: String) -> String {
        switch title {
        case "Buyurtmalar tarixi": return "O'tgan buyurtmalaringizni ko'ring"
        case "Yetkazib berish manzili": return "Manzillaringizni boshqaring"
        case "Ilovani ulashish": return "Do‘stlaringiz bilan baham ko‘ring"
        case "Sozlamalar": return "Ilova sozlamalari"
        case "Ilovani baholang": return "Fikr-mulohazangizni qoldiring"
        case "Chiqish": return "Akkountdan chiqish"
        default: return ""
        }
    }

    // MARK: - Actions
    @objc private func menuTapped(_ sender: UITapGestureRecognizer) {
        guard let title = sender.view?.accessibilityLabel else { return }

        switch title {

        // OPEN ADDRESS SETTINGS SCREEN
        case "Yetkazib berish manzili":
            let vc = AddressSettingsVC()
            navigationController?.pushViewController(vc, animated: true)
            return

        // LOGOUT
        case "Chiqish":
            print("LOGOUT")
            return

        default:
            print("Tapped \(title)")
            return
        }
    }

    @objc private func openEdit() {
        // we'll push a navigation-wrapped EditProfileVC for a custom header look.
        let edit = EditProfileVC()
        navigationController?.pushViewController(edit, animated: true)
    }

    // MARK: - Load / Refresh
    private func loadProfileFromStorage() {
        let ud = UserDefaults.standard
        if let first = ud.string(forKey: Keys.firstName), !first.isEmpty {
            nameLabel.text = first + (ud.string(forKey: Keys.lastName).map { " \($0)" } ?? "")
        } else {
            nameLabel.text = "Sardor Karimov"
        }

        // phone: for now read from UserDefaults if present; will switch to Firebase Auth later.
        if let phone = ud.string(forKey: Keys.phone), !phone.isEmpty {
            phoneLabel.text = phone
        } else {
            phoneLabel.text = "+998 90 123 45 67" // placeholder
        }

        if let data = ud.data(forKey: Keys.imageData), let img = UIImage(data: data) {
            profileImageView.image = img
        }
    }
}




