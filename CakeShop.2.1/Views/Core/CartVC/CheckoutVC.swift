

// CheckoutVC.swift
// Paste/replace your CheckoutVC with this file

import UIKit
import MapKit
import CoreLocation

final class CheckoutVC: UIViewController {

    // MARK: - Keys (same as other files)
    private enum Keys {
        static let savedAddress = "saved_address"
        static let savedLat = "saved_lat"
        static let savedLon = "saved_lon"
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let addressCard = CheckoutCardView(title: "Yetkazib berish manzili")
    private let timeCard = CheckoutCardView(title: "Yetkazib berish vaqti")
    private let noteCard = CheckoutCardView(title: "Qo'shimcha izoh")
    private let paymentCard = CheckoutCardView(title: "To'lov usuli")

    // Address UI inside addressCard
    private let addressLabel = UILabel()
    private let addressThumbnail = UIImageView()
    private let changeAddressButton = UIButton(type: .system)
    private let useMyLocationButton = UIButton(type: .system)

    // Date/time
    private let dateField = DateFieldView(placeholder: "Kunni tanlang")
    private var selectedDate: Date?

    private let timeslotContainer = UIStackView()
    private var timeSlotButtons: [TimeSlotButton] = []
    private var selectedTimeSlot: String?

    // Note
    private let noteTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.isScrollEnabled = false
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 0.5
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        // set 16pt inset visually inside the rounded border
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        // remove internal line fragment padding so text and our placeholder align exactly
        tv.clipsToBounds = true        // ← FIX 1
        tv.layer.masksToBounds = true
        
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = UIColor(white: 0.98, alpha: 1)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let notePlaceholder: UILabel = {
        let lbl = UILabel()
        lbl.text = "Bu masalan qo'shimcha telefon yoki eslatma bo'lishi mumkin."
        lbl.textColor = .systemGray3
        lbl.font = .systemFont(ofSize: 15)
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byWordWrapping
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    // Payment
    private let paymentStack = UIStackView()
    private let cashButton = UIButton(type: .system)
    private let cardButton = UIButton(type: .system)
    private var selectedPayment: PaymentMethod?

    private enum PaymentMethod { case cash, card }

    // Bottom
    private let bottomSummary = UIView()
    private let productsTotalLabel = UILabel()
    private let deliveryLabel = UILabel()
    private let grandTotalLabel = UILabel()
    private let confirmButton = UIButton(type: .system)

    private let timeSlots = [
        "09:00 - 11:00", "11:00 - 13:00",
        "13:00 - 15:00", "15:00 - 17:00",
        "17:00 - 19:00", "19:00 - 21:00"
    ]

    // selected address
    private var selectedAddressText: String?
    private var selectedCoordinate: CLLocationCoordinate2D?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.98, alpha: 1)
        title = "Buyurtmani rasmiylashtirish"

        setupNavigation()
        setupScrollStack()
        setupAddressCard()
        setupTimeCard()
        setupNoteCard()
        setupPaymentCard()
        setupBottomSummary()
        
        selectedPayment = .cash
        updatePaymentUI()

        loadSavedAddressIfAny()
        updateTotals()
        registerNotifications()
        addTapToDismissKeyboard()

        dateField.onTap = { [weak self] in self?.presentDatePicker() }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup helpers
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = "Buyurtmani rasmiylashtirish"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        
        navigationController?.navigationBar.tintColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)

    }

    private func setupScrollStack() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -160),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -200)

        ])
    }

    // MARK: - Address card
    
    private func setupAddressCard() {

        // === CONFIGURABLE OFFSET (move chevron up/down) ===
        let chevronCenterYOffset: CGFloat = -4   // negative = up, positive = down

        // === TITLE ===
        let titleLabel = UILabel()
        titleLabel.text = "Yetkazib berish manzili"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // === ROW: dot + address ===
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        let dot = UIView()
        dot.backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        dot.layer.cornerRadius = 6
        dot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12)
        ])

        addressLabel.font = .systemFont(ofSize: 16)
        addressLabel.textColor = .label
        addressLabel.numberOfLines = 1
        addressLabel.lineBreakMode = .byTruncatingTail
        addressLabel.text = "Manzil tanlanmagan"

        row.addArrangedSubview(dot)
        row.addArrangedSubview(addressLabel)

        // === LEFT COLUMN ===
        let leftColumn = UIStackView(arrangedSubviews: [titleLabel, row])
        leftColumn.axis = .vertical
        leftColumn.spacing = 2
        leftColumn.translatesAutoresizingMaskIntoConstraints = false
        

        // === CHEVRON (independent from row!) ===
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chevron.widthAnchor.constraint(equalToConstant: 18),
            chevron.heightAnchor.constraint(equalToConstant: 18)
        ])

        // === MAIN CONTAINER ===
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(leftColumn)
        container.addSubview(chevron)

        // LEFT COLUMN
        NSLayoutConstraint.activate([
            leftColumn.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            leftColumn.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            leftColumn.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            leftColumn.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -12)
        ])

        // CHEVRON — adjustable vertical position 🎯
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),

            // MAGIC OFFSET HERE
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor,
                                             constant: chevronCenterYOffset)
        ])

        // PUT INSIDE CARD
        addressCard.setContent(view: container)
        contentStack.addArrangedSubview(addressCard)

        addressCard.heightAnchor.constraint(equalToConstant: 90).isActive = true

        // TAP
        let tap = UITapGestureRecognizer(target: self, action: #selector(openAddressSelector))
        addressCard.addGestureRecognizer(tap)
        addressCard.isUserInteractionEnabled = true
    }


    private func loadSavedAddressIfAny() {
        let ud = UserDefaults.standard
        if let addr = ud.string(forKey: Keys.savedAddress) {
            selectedAddressText = addr
            addressLabel.text = addr
            if let lat = ud.value(forKey: Keys.savedLat) as? CLLocationDegrees,
               let lon = ud.value(forKey: Keys.savedLon) as? CLLocationDegrees {
                selectedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                generateSnapshotForCheckout(lat: lat, lon: lon)
            } else {
                addressThumbnail.image = nil
            }
        } else {
            addressLabel.text = "Manzil tanlanmagan. Manzilni xaritada tanlang."
            addressThumbnail.image = nil
            selectedAddressText = nil
            selectedCoordinate = nil
        }
    }

    private func generateSnapshotForCheckout(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let options = MKMapSnapshotter.Options()
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: 600, longitudinalMeters: 600)
        options.region = region
        options.size = CGSize(width: 88, height: 88) // square thumbnail
        options.scale = UIScreen.main.scale
        options.pointOfInterestFilter = .includingAll

        let snapper = MKMapSnapshotter(options: options)
        snapper.start { [weak self] snapshot, _ in
            guard let self = self else { return }
            if let snapshot = snapshot {
                UIGraphicsBeginImageContextWithOptions(options.size, true, options.scale)
                snapshot.image.draw(at: .zero)
                if let pin = UIImage(systemName: "mappin.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
                    let pt = snapshot.point(for: coord)
                    let pinPoint = CGPoint(x: pt.x - pin.size.width / 2, y: pt.y - pin.size.height)
                    pin.draw(at: pinPoint)
                }
                let final = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                DispatchQueue.main.async {
                    self.addressThumbnail.image = final
                }
            } else {
                DispatchQueue.main.async {
                    self.addressThumbnail.image = nil
                }
            }
        }
    }

    // MARK: - Time card (unchanged)
    private func setupTimeCard() {
        dateField.translatesAutoresizingMaskIntoConstraints = false
        dateField.heightAnchor.constraint(equalToConstant: 56).isActive = true

        timeslotContainer.axis = .vertical
        timeslotContainer.spacing = 12
        timeslotContainer.translatesAutoresizingMaskIntoConstraints = false

        var currentRow: UIStackView?

        for (index, slot) in timeSlots.enumerated() {
            if index % 3 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 12
                currentRow?.distribution = .fillEqually
                timeslotContainer.addArrangedSubview(currentRow!)
            }

            let btn = TimeSlotButton(title: slot)
            btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
            btn.addTarget(self, action: #selector(timeSlotTapped(_:)), for: .touchUpInside)
            timeSlotButtons.append(btn)
            currentRow?.addArrangedSubview(btn)
        }

        let v = UIStackView(arrangedSubviews: [dateField, timeslotContainer])
        v.axis = .vertical
        v.spacing = 12

        timeCard.setContent(view: v)
        contentStack.addArrangedSubview(timeCard)
    }

    private func setupNoteCard() {
        noteTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        noteTextView.delegate = self

        // add placeholder *inside* the textView so it scrolls with content if needed
        noteTextView.addSubview(notePlaceholder)

        // Constrain placeholder to be exactly 16pt from each side of the visible area
        NSLayoutConstraint.activate([
            notePlaceholder.topAnchor.constraint(equalTo: noteTextView.topAnchor, constant: 16),
            notePlaceholder.leadingAnchor.constraint(equalTo: noteTextView.leadingAnchor, constant: 16),
            notePlaceholder.widthAnchor.constraint(equalTo: noteTextView.widthAnchor, constant: -32)
        ])

        noteCard.setContent(view: noteTextView)
        contentStack.addArrangedSubview(noteCard)

        // spacer
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        contentStack.addArrangedSubview(spacer)

        // set initial placeholder visibility (in case the text view has prefilled text)
        notePlaceholder.isHidden = !noteTextView.text.isEmpty
    }


    private func setupPaymentCard() {
        paymentStack.axis = .horizontal
        paymentStack.distribution = .fillEqually
        paymentStack.spacing = 12
        paymentStack.translatesAutoresizingMaskIntoConstraints = false
        

        // Cash
        cashButton.translatesAutoresizingMaskIntoConstraints = false
        cashButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cashButton.layer.cornerRadius = 12
        cashButton.layer.borderWidth = 1
        cashButton.layer.borderColor = UIColor.systemGray4.cgColor
        cashButton.backgroundColor = .white
        cashButton.setTitle("Naqd pul", for: .normal)
        cashButton.setImage(UIImage(systemName: "banknote"), for: .normal)
        cashButton.tintColor = .systemPink
        cashButton.addTarget(self, action: #selector(selectCash), for: .touchUpInside)

        // Card
        cardButton.translatesAutoresizingMaskIntoConstraints = false
        cardButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cardButton.layer.cornerRadius = 12
        cardButton.layer.borderWidth = 1
        cardButton.layer.borderColor = UIColor.systemGray4.cgColor
        cardButton.backgroundColor = .white
        cardButton.setTitle("Kartadan to'lash", for: .normal)
        cardButton.setImage(UIImage(systemName: "creditcard"), for: .normal)
        cardButton.tintColor = .systemPink
        cardButton.addTarget(self, action: #selector(selectCard), for: .touchUpInside)

        paymentStack.addArrangedSubview(cashButton)
        paymentStack.addArrangedSubview(cardButton)

        paymentCard.setContent(view: paymentStack)
        contentStack.addArrangedSubview(paymentCard)

    }

    private func updatePaymentUI() {
        let selectedColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        let normalBorder = UIColor.systemGray4.cgColor

        switch selectedPayment {
        case .cash:
            cashButton.backgroundColor = selectedColor
            cashButton.setTitleColor(.white, for: .normal)
            cashButton.tintColor = .white
            cashButton.layer.borderColor = UIColor.clear.cgColor

            cardButton.backgroundColor = .white
            cardButton.setTitleColor(.label, for: .normal)
            cardButton.tintColor = .systemPink
            cardButton.layer.borderColor = normalBorder
        case .card:
            cardButton.backgroundColor = selectedColor
            cardButton.setTitleColor(.white, for: .normal)
            cardButton.tintColor = .white
            cardButton.layer.borderColor = UIColor.clear.cgColor

            cashButton.backgroundColor = .white
            cashButton.setTitleColor(.label, for: .normal)
            cashButton.tintColor = .systemPink
            cashButton.layer.borderColor = normalBorder
        case .none:
            cashButton.backgroundColor = .white
            cashButton.setTitleColor(.label, for: .normal)
            cashButton.tintColor = .systemPink
            cashButton.layer.borderColor = normalBorder

            cardButton.backgroundColor = .white
            cardButton.setTitleColor(.label, for: .normal)
            cardButton.tintColor = .systemPink
            cardButton.layer.borderColor = normalBorder
        }
    }

    private func setupBottomSummary() {
        bottomSummary.translatesAutoresizingMaskIntoConstraints = false
        bottomSummary.backgroundColor = .white
        bottomSummary.layer.cornerRadius = 16
        bottomSummary.layer.masksToBounds = true

        view.addSubview(bottomSummary)

        productsTotalLabel.font = .systemFont(ofSize: 14)
        deliveryLabel.font = .systemFont(ofSize: 14)
        grandTotalLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        [productsTotalLabel, deliveryLabel, grandTotalLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bottomSummary.addSubview($0)
        }

        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("Buyurtmani tasdiqlash", for: .normal)
        confirmButton.backgroundColor = UIColor(red: 0.95, green: 0.22, blue: 0.56, alpha: 1)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        confirmButton.layer.cornerRadius = 28
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        bottomSummary.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            bottomSummary.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomSummary.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bottomSummary.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomSummary.heightAnchor.constraint(equalToConstant: 170),

            productsTotalLabel.topAnchor.constraint(equalTo: bottomSummary.topAnchor, constant: 18),
            productsTotalLabel.leadingAnchor.constraint(equalTo: bottomSummary.leadingAnchor, constant: 16),

            deliveryLabel.topAnchor.constraint(equalTo: productsTotalLabel.bottomAnchor, constant: 8),
            deliveryLabel.leadingAnchor.constraint(equalTo: bottomSummary.leadingAnchor, constant: 16),

            grandTotalLabel.topAnchor.constraint(equalTo: deliveryLabel.bottomAnchor, constant: 12),
            grandTotalLabel.leadingAnchor.constraint(equalTo: bottomSummary.leadingAnchor, constant: 16),

            confirmButton.leadingAnchor.constraint(equalTo: bottomSummary.leadingAnchor, constant: 16),
            confirmButton.trailingAnchor.constraint(equalTo: bottomSummary.trailingAnchor, constant: -16),
            confirmButton.bottomAnchor.constraint(equalTo: bottomSummary.bottomAnchor, constant: -16),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Actions

    @objc private func openAddressSelector() {
        let selector = AddressSelectorVC()
        selector.onAddressSelected = { [weak self] coordinate, address in
            guard let self = self else { return }
            // save single address in UserDefaults (keeps consistent)
            UserDefaults.standard.setValue(address, forKey: Keys.savedAddress)
            UserDefaults.standard.setValue(coordinate.latitude, forKey: Keys.savedLat)
            UserDefaults.standard.setValue(coordinate.longitude, forKey: Keys.savedLon)
            UserDefaults.standard.synchronize()

            self.selectedAddressText = address
            self.selectedCoordinate = coordinate
            self.addressLabel.text = address
            self.generateSnapshotForCheckout(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        let nav = UINavigationController(rootViewController: selector)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func useCurrentLocationTapped() {
        // open MapSelectionVC but center on user location and pick it
        let mapVC = MapSelectionVC()
        mapVC.pickCurrentLocationImmediately = true
        mapVC.onLocationPicked = { [weak self] coord, address in
            guard let self = self else { return }
            UserDefaults.standard.setValue(address, forKey: Keys.savedAddress)
            UserDefaults.standard.setValue(coord.latitude, forKey: Keys.savedLat)
            UserDefaults.standard.setValue(coord.longitude, forKey: Keys.savedLon)
            UserDefaults.standard.synchronize()

            self.selectedAddressText = address
            self.selectedCoordinate = coord
            self.addressLabel.text = address
            self.generateSnapshotForCheckout(lat: coord.latitude, lon: coord.longitude)
        }
        navigationController?.pushViewController(mapVC, animated: true)
    }

    @objc private func timeSlotTapped(_ sender: TimeSlotButton) {
        for btn in timeSlotButtons { btn.isSelected = (btn == sender) }
        selectedTimeSlot = sender.titleText
    }

    @objc private func selectCash() { selectedPayment = .cash; updatePaymentUI() }
    @objc private func selectCard() { selectedPayment = .card; updatePaymentUI() }

    @objc private func confirmTapped() {
        guard let address = selectedAddressText else {
            showSimpleAlert(title: "Xatolik", message: "Iltimos, yetkazib berish manzilini tanlang.")
            return
        }
        guard let coordinate = selectedCoordinate else {
            showSimpleAlert(title: "Xatolik", message: "Manzil koordinatalari topilmadi.")
            return
        }
        guard let date = selectedDate else {
            showSimpleAlert(title: "Xatolik", message: "Iltimos, yetkazib berish kunini tanlang.")
            return
        }
        guard let timeslot = selectedTimeSlot else {
            showSimpleAlert(title: "Xatolik", message: "Iltimos, yetkazib berish vaqtini tanlang.")
            return
        }
        guard let payment = selectedPayment else {
            showSimpleAlert(title: "Xatolik", message: "Iltimos, to'lov usulini tanlang.")
            return
        }

        // Payment text
        let paymentText = (payment == .cash) ? "Naqd pul" : "Kartadan to'lash"

        // Build order items
        let orderItems: [OrderItem] = CartManager.shared.items.map { item in
            
            let standardOptions = StandardCakeOptions(
                innerFlavors: item.cake.innerFlavors,
                outerCoating: item.cake.outerCoating,
                innerCoating: item.cake.innerCoating,
                toppings: item.cake.toppings
            )

            return OrderItem(
                id: item.cake.id,
                name: item.cake.name,
                category: item.cake.category,
                quantity: item.quantity,
                serving: item.serving,
                unitPrice: item.unitPrice,
                totalPrice: item.unitPrice * item.quantity,
                images: item.cake.images,
                type: .standard,
                standardOptions: standardOptions,
                customOptions: nil
            )
        }

        // Build full order object
        let order = Order(
            address: address,
            coordinate: coordinate,
            date: date,
            timeSlot: timeslot,
            paymentMethod: paymentText,
            note: noteTextView.text.isEmpty ? nil : noteTextView.text,
            items: orderItems
        )

        // Format message for Telegram
        let telegramMessage = self.formatOrderForTelegram(order)

        // Send to Telegram
        self.sendToTelegram(text: telegramMessage)

        // (Optional) Save to Firebase
        // self.saveOrderToFirebase(order)

        // Clear cart & update UI
        CartManager.shared.clear()
        NotificationCenter.default.post(name: .cartUpdated, object: nil)

        // Status popup for user
        self.showSimpleAlert(title: "Buyurtma qabul qilindi",
                             message: "Rahmat! Sizning buyurtmangiz qabul qilindi.")

        self.navigationController?.popViewController(animated: true)
    }

    
    private func formatOrderForTelegram(_ order: Order) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none

        let lat = order.coordinate.latitude
        let lon = order.coordinate.longitude
        let mapLink = "https://www.google.com/maps?q=\(lat),\(lon)"

        var text = ""
        text += "📦 <b>Yangi buyurtma</b>\n\n"
        text += "📍 <b>Manzil:</b> \(order.address)\n"
        text += "📌 <b>Lokatsiya:</b> <a href=\"\(mapLink)\">Xaritada ko'rish</a>\n"
        text += "🗓 <b>Sana:</b> \(df.string(from: order.date))\n"
        text += "⏰ <b>Vaqt:</b> \(order.timeSlot)\n"
        text += "💳 <b>To'lov:</b> \(order.paymentMethod)\n"

        if let note = order.note, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            text += "📝 <b>Izoh:</b> \(note)\n"
        }

        text += "\n🍰 <b>Mahsulotlar:</b>\n"

        for (i, item) in order.items.enumerated() {
            text += "\n<b>\(i + 1). \(item.name)</b>\n"
            text += "   • Kategoriya: \(item.category)\n"
            text += "   • Porsiya: \(item.serving)\n"
            text += "   • Soni: \(item.quantity)\n"
            text += "   • Narx (dona): \(formatCurrency(item.unitPrice))\n"
            text += "   • Jami: \(formatCurrency(item.totalPrice))\n"

            if let opts = item.standardOptions {
                if let inner = opts.innerFlavors, !inner.isEmpty {
                    text += "   • Ichki ta'mlar: \(inner.joined(separator: ", "))\n"
                }
                if let innerCoat = opts.innerCoating, !innerCoat.isEmpty {
                    text += "   • Ichki qoplama: \(innerCoat.joined(separator: ", "))\n"
                }
                if let outer = opts.outerCoating, !outer.isEmpty {
                    text += "   • Tashqi qoplama: \(outer.joined(separator: ", "))\n"
                }
                if let tops = opts.toppings, !tops.isEmpty {
                    text += "   • Topping: \(tops.joined(separator: ", "))\n"
                }
            }

            if let custom = item.customOptions {
                text += "   • (Custom cake details)\n"
                if let shape = custom.shape { text += "     – Shape: \(shape)\n" }
                if let layers = custom.layers { text += "     – Layers: \(layers)\n" }
                if let color = custom.color { text += "     – Color: \(color)\n" }
                if let filling = custom.filling { text += "     – Filling: \(filling)\n" }
                if let cream = custom.creamType { text += "     – Cream: \(cream)\n" }
                if let dec = custom.decorations, !dec.isEmpty { text += "     – Decorations: \(dec.joined(separator: ", "))\n" }
                if let msg = custom.messageOnCake { text += "     – Text on cake: \(msg)\n" }
                if let w = custom.weightInKg { text += "     – Weight: \(w) kg\n" }
            }

            if let firstImage = item.images.first {
                text += "   • Image: \(firstImage)\n"
            }
        }

        text += "\n💰 <b>Umumiy summa:</b> \(formatCurrency(CartManager.shared.total))\n"
        text += "📩 Buyurtma ID: \(UUID().uuidString.prefix(8))"

        return text
    }

    
    private func sendToTelegram(text: String) {
        let botToken = "7957152277:AAE_nLVtJLSRRbs3WDt-hzlaZ-D1UIksxbQ"
        let chatId = "-5040591938"

        let urlString = "https://api.telegram.org/bot\(botToken)/sendMessage"
        guard let url = URL(string: urlString) else { return }

        let params: [String: Any] = [
            "chat_id": chatId,
            "text": text,
            "parse_mode": "HTML"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)

        URLSession.shared.dataTask(with: request).resume()
    }

    

    // MARK: - Date picker
    private func presentDatePicker() {
        let popup = CalendarPopupView(frame: view.bounds)
        popup.alpha = 0
        popup.onDateSelected = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
            let fmt = DateFormatter(); fmt.dateStyle = .medium
            self.dateField.setText(fmt.string(from: date))
        }
        view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: view.topAnchor),
            popup.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        UIView.animate(withDuration: 0.25) { popup.alpha = 1 }
    }

    // MARK: - Helpers
    private func updateTotals() {
        productsTotalLabel.text = "Mahsulotlar: \(formatCurrency(CartManager.shared.subtotal))"
        deliveryLabel.text = "Yetkazib berish: \(formatCurrency(CartManager.shared.deliveryCost))"
        grandTotalLabel.text = "Jami: \(formatCurrency(CartManager.shared.total))"
    }

    private func formatCurrency(_ value: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; f.groupingSeparator = " "
        let s = f.string(from: NSNumber(value: value)) ?? "\(value)"
        return s + " so'm"
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(cartUpdated), name: .cartUpdated, object: nil)
    }
    @objc private func cartUpdated() { updateTotals() }

    private func addTapToDismissKeyboard() {
        let t = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        t.cancelsTouchesInView = false
        view.addGestureRecognizer(t)
    }
    @objc private func handleTap() { view.endEditing(true) }

    @objc private func backTapped() { navigationController?.popViewController(animated: true) }

    private func showSimpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
extension CheckoutVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notePlaceholder.isHidden = !textView.text.isEmpty
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        notePlaceholder.isHidden = !textView.text.isEmpty
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        notePlaceholder.isHidden = !textView.text.isEmpty
    }
}


