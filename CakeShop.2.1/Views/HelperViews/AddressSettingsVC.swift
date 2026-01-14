//
//  AddressSettingsVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 23/11/25.
//

import UIKit
import MapKit
import CoreLocation

final class AddressSettingsVC: UIViewController {

    // MARK: - UI
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()

    private let cardView = UIView()
    private let addressTitleLabel = UILabel()
    private let addressLabel = UILabel()
    private let mapThumbnail = UIImageView()
    private let changeButton = UIButton(type: .system)
    private let removeButton = UIButton(type: .system)

    // MARK: - Keys (UserDefaults)
    private enum Keys {
        static let savedAddress = "saved_address"
        static let savedLat = "saved_lat"
        static let savedLon = "saved_lon"
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupHeader()
        setupCard()
        loadSavedAndRender()
    }

    // MARK: - Header
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(red: 0.93, green: 0.19, blue: 0.54, alpha: 1)
        headerView.layer.cornerRadius = 20
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.clipsToBounds = true
        view.addSubview(headerView)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor(white: 1, alpha: 0.12)
        backButton.layer.cornerRadius = 22
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerView.addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Yetkazib berish manzili"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 110),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }

    // MARK: - Card UI
    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.04
        cardView.layer.shadowRadius = 6
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.addSubview(cardView)

        addressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addressTitleLabel.text = "Asosiy manzil"
        addressTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        addressTitleLabel.textColor = .secondaryLabel

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.text = "Manzil yo'q. Manzil qo'shing."
        addressLabel.font = .systemFont(ofSize: 15)
        addressLabel.textColor = .label
        addressLabel.numberOfLines = 2

        mapThumbnail.translatesAutoresizingMaskIntoConstraints = false
        mapThumbnail.backgroundColor = UIColor.systemGray6
        mapThumbnail.layer.cornerRadius = 10
        mapThumbnail.clipsToBounds = true
        mapThumbnail.contentMode = .scaleAspectFill

        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.setTitle("Manzilni o'zgartirish", for: .normal)
        changeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        changeButton.layer.cornerRadius = 12
        changeButton.backgroundColor = UIColor.systemPink
        changeButton.setTitleColor(.white, for: .normal)
        changeButton.addTarget(self, action: #selector(changeTapped), for: .touchUpInside)

        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.setTitle("Manzilni o'chirish", for: .normal)
        removeButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        removeButton.setTitleColor(.systemRed, for: .normal)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)

        cardView.addSubview(addressTitleLabel)
        cardView.addSubview(addressLabel)
        cardView.addSubview(mapThumbnail)
        cardView.addSubview(changeButton)
        cardView.addSubview(removeButton)

        let top = headerView.bottomAnchor
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: top, constant: 18),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            addressTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            addressTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            addressTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            addressLabel.topAnchor.constraint(equalTo: addressTitleLabel.bottomAnchor, constant: 8),
            addressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            addressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            mapThumbnail.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 12),
            mapThumbnail.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            mapThumbnail.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            mapThumbnail.heightAnchor.constraint(equalToConstant: 160),

            changeButton.topAnchor.constraint(equalTo: mapThumbnail.bottomAnchor, constant: 12),
            changeButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            changeButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            changeButton.heightAnchor.constraint(equalToConstant: 48),

            removeButton.topAnchor.constraint(equalTo: changeButton.bottomAnchor, constant: 8),
            removeButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            removeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Load / Render
    private func loadSavedAndRender() {
        let ud = UserDefaults.standard
        if let address = ud.string(forKey: Keys.savedAddress) {
            addressLabel.text = address
            if let lat = ud.value(forKey: Keys.savedLat) as? CLLocationDegrees,
               let lon = ud.value(forKey: Keys.savedLon) as? CLLocationDegrees {
                generateSnapshotAndShow(lat: lat, lon: lon)
            } else {
                mapThumbnail.image = nil
            }
        } else {
            addressLabel.text = "Manzil yo'q. Manzil qo'shing."
            mapThumbnail.image = nil
        }
    }

    // MARK: - Snapshot
    private func generateSnapshotAndShow(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let options = MKMapSnapshotter.Options()
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: 800, longitudinalMeters: 800)
        options.region = region
        options.size = CGSize(width: view.bounds.width - 64, height: 160) // match thumbnail width minus margins
        options.scale = UIScreen.main.scale
        options.showsBuildings = true
        options.pointOfInterestFilter = .includingAll

        let snapper = MKMapSnapshotter(options: options)
        snapper.start { [weak self] snapshot, error in
            guard let self = self else { return }
            if let snapshot = snapshot {
                // draw pin onto snapshot
                UIGraphicsBeginImageContextWithOptions(options.size, true, options.scale)
                snapshot.image.draw(at: .zero)

                // draw pin (red) at the right point
                let pin = UIImage(systemName: "mappin.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
                if let pin = pin {
                    let point = snapshot.point(for: coord)
                    // center pin horizontally, pin top above point
                    let pinPoint = CGPoint(x: point.x - (pin.size.width / 2), y: point.y - pin.size.height)
                    pin.draw(at: pinPoint)
                }

                let final = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                DispatchQueue.main.async {
                    self.mapThumbnail.image = final
                }
            } else {
                DispatchQueue.main.async {
                    self.mapThumbnail.image = nil
                }
            }
        }
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func changeTapped() {
        let mapVC = MapSelectionVC()
        mapVC.onLocationPicked = { [weak self] coordinate, address in
            guard let self = self else { return }
            // Save to UserDefaults
            UserDefaults.standard.set(address, forKey: Keys.savedAddress)
            UserDefaults.standard.set(coordinate.latitude, forKey: Keys.savedLat)
            UserDefaults.standard.set(coordinate.longitude, forKey: Keys.savedLon)
            UserDefaults.standard.synchronize()

            // Update UI
            self.addressLabel.text = address ?? "Manzil saqlandi"
            self.generateSnapshotAndShow(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        navigationController?.pushViewController(mapVC, animated: true)
    }

    @objc private func removeTapped() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: Keys.savedAddress)
        ud.removeObject(forKey: Keys.savedLat)
        ud.removeObject(forKey: Keys.savedLon)
        ud.synchronize()
        loadSavedAndRender()
    }
}
