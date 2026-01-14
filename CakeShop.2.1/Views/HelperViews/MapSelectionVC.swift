//
//  MapSelectionVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov
//




// MapSelectionVC.swift
// Redesigned map picker: search + map + center pin + save.

import UIKit
import MapKit
import CoreLocation

final class MapSelectionVC: UIViewController {
    
    private let locationButton = UIButton(type: .system)

    private let mapView = MKMapView()
    private let headerContainer = UIView()
    private let searchBar = UISearchBar()
    private let centerPin = UIImageView(image: UIImage(named: "MapPinOrange"))
    private let saveButton = UIButton(type: .system)
    private let addressLabel = UILabel()
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    private var isDraggingMap = false

    // Behavior flags
    var pickCurrentLocationImmediately: Bool = false

    /// Callback when user picks location
    var onLocationPicked: ((_ coordinate: CLLocationCoordinate2D, _ address: String?) -> Void)?

    // quick search results table
    private let tableView = UITableView()
    private var searchResults: [MKMapItem] = []

    private var lastAddress: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("MapSelectionVC Opened")
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupLocationButton()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        setupHeader()
        setupMapView()
        setupCenterPin()
        setupAddressLabel()
        setupSaveButton()
        setupSearchResultsTable()

        // 🔥 FIX: ensure FAB is visible
        view.bringSubviewToFront(locationButton)
        view.bringSubviewToFront(headerContainer)
        view.bringSubviewToFront(centerPin)
        view.bringSubviewToFront(saveButton)
        view.bringSubviewToFront(addressLabel)
        view.bringSubviewToFront(tableView)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if pickCurrentLocationImmediately {
            centerOnUserLocation()
            reverseGeocodeCenter()
        } else {
            // center when we have a location
            centerOnUserLocation()
        }
    }

    // MARK: - UI setup
    
    private func setupLocationButton() {
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.backgroundColor = .white
        locationButton.layer.cornerRadius = 25
        locationButton.layer.shadowOpacity = 0.25
        locationButton.layer.shadowRadius = 6
        locationButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        locationButton.tintColor = .systemBlue
        locationButton.addTarget(self, action: #selector(centerOnUserTapped), for: .touchUpInside)

        // Make sure it is on the SAME view as saveButton
        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // FIX: Use safe area, not saveButton.topAnchor
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -110)
        ])
    }

    
    @objc private func centerOnUserTapped() {
        let status = locationManager.authorizationStatus

        switch status {
        case .denied, .restricted:
            showLocationDeniedAlert()
            return
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        default:
            break
        }

        guard let loc = mapView.userLocation.location else { return }

        let region = MKCoordinateRegion(
            center: loc.coordinate,
            latitudinalMeters: 300,
            longitudinalMeters: 300
        )
        mapView.setRegion(region, animated: true)
    }

    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Ruxsat berilmadi",
            message: "Joylashuvga ruxsat berishingiz kerak.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Sozlamalar", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Bekor qilish", style: .cancel))
        present(alert, animated: true)
    }



    private func setupHeader() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = .white
        headerContainer.layer.cornerRadius = 12
        headerContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.addSubview(headerContainer)

        // Place header as a small top bar (search inside)
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            headerContainer.heightAnchor.constraint(equalToConstant: 56)
        ])

        // Back button
        let back = UIButton(type: .system)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        back.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        headerContainer.addSubview(back)

        // SearchBar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Manzil qidirish"
        searchBar.delegate = self
        headerContainer.addSubview(searchBar)

        NSLayoutConstraint.activate([
            back.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 8),
            back.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            back.widthAnchor.constraint(equalToConstant: 40),

            searchBar.leadingAnchor.constraint(equalTo: back.trailingAnchor, constant: 6),
            searchBar.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
    }

    private func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupCenterPin() {
        centerPin.translatesAutoresizingMaskIntoConstraints = false
        centerPin.tintColor = .systemPink
        centerPin.alpha = 1
        view.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),
            centerPin.widthAnchor.constraint(equalToConstant: 19),
            centerPin.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupAddressLabel() {
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = .systemFont(ofSize: 15, weight: .medium)
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 2
        addressLabel.textColor = .label
        view.addSubview(addressLabel)
        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -140)
        ])
    }

    private func setupSaveButton() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Select this address", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        saveButton.backgroundColor = UIColor.systemYellow
        saveButton.layer.cornerRadius = 12
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupSearchResultsTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "r")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func saveTapped() {
        let center = mapView.centerCoordinate
        reverseGeocodeCoordinate(center) { [weak self] address in
            guard let self = self else { return }
            self.onLocationPicked?(center, address)
            self.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Helpers

    private func centerOnUserLocation() {
        if let loc = mapView.userLocation.location {
            let r = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
            mapView.setRegion(r, animated: true)
            updateAddressForCenter()
        } else {
            // request once; will center in delegate when available
            locationManager.requestLocation()
        }
    }

    private func reverseGeocodeCenter() {
        let c = mapView.centerCoordinate
        reverseGeocodeCoordinate(c) { [weak self] address in
            self?.addressLabel.text = address
            self?.lastAddress = address
        }
    }

    private func reverseGeocodeCoordinate(_ coord: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        geoCoder.cancelGeocode()
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geoCoder.reverseGeocodeLocation(loc) { placemarks, _ in
            if let p = placemarks?.first {
                let text = [p.thoroughfare, p.subThoroughfare, p.locality]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                completion(text.isEmpty ? nil : text)
            } else {
                completion(nil)
            }
        }
    }

    private func updateAddressForCenter() {
        let c = mapView.centerCoordinate
        reverseGeocodeCoordinate(c) { [weak self] address in
            self?.addressLabel.text = address
            self?.lastAddress = address
        }
    }

    // lift/drop animations
    private func liftPin() {
        guard !isDraggingMap else { return }
        isDraggingMap = true
        UIView.animate(withDuration: 0.15) {
            self.centerPin.transform = CGAffineTransform(translationX: 0, y: -20)
            self.centerPin.alpha = 0.9
        }
    }
    private func dropPin() {
        guard isDraggingMap else { return }
        isDraggingMap = false
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.centerPin.transform = .identity
            self.centerPin.alpha = 1
        }
    }
}

// MARK: - Map delegate / region changes
extension MapSelectionVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        liftPin()
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        dropPin()
        updateAddressForCenter()
    }
}

// MARK: - Location manager
extension MapSelectionVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if pickCurrentLocationImmediately, let loc = locations.first {
            let r = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            mapView.setRegion(r, animated: true)
            updateAddressForCenter()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { /* ignore */ }
}

// MARK: - Search
extension MapSelectionVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let q = searchBar.text, !q.isEmpty else { return }
        let req = MKLocalSearch.Request(); req.naturalLanguageQuery = q
        let s = MKLocalSearch(request: req)
        s.start { [weak self] resp, _ in
            guard let self = self else { return }
            self.searchResults = resp?.mapItems ?? []
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults.removeAll()
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
}

extension MapSelectionVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { searchResults.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = searchResults[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "r", for: indexPath)
        c.textLabel?.text = [item.name, item.placemark.title].compactMap { $0 }.joined(separator: " — ")
        c.textLabel?.numberOfLines = 2
        return c
    }
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = searchResults[indexPath.row]
        // center map and hide results
        mapView.setCenter(item.placemark.coordinate, animated: true)
        tableView.isHidden = true
        searchBar.resignFirstResponder()
        updateAddressForCenter()
    }
}





//
//import UIKit
//import MapKit
//import CoreLocation
//
//final class MapSelectionVC: UIViewController {
//
//    private let mapView = MKMapView()
//    private let headerView = UIView()
//    private let centerPin = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
//    private let locationButton = UIButton(type: .custom)
//    private let saveButton = UIButton(type: .system)
//    private let addressLabel = UILabel()
//    private let backButton = UIButton(type: .system)
//
//    private let locationManager = CLLocationManager()
//    private let geoCoder = CLGeocoder()
//
//    private var lastAddress: String?
//    
//    private var isDraggingMap = false
//
//
//    /// Callback when user picks location
//    var onLocationPicked: ((_ coordinate: CLLocationCoordinate2D, _ address: String?) -> Void)?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        navigationController?.setNavigationBarHidden(true, animated: false)
//        view.backgroundColor = .systemBackground
//
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//
//        setupHeader()
//        setupMapView()
//        setupCenterPin()
//        setupAddressLabel()
//        setupSaveButton()
//        setupLocationButton()     // last so it appears above everything
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        centerOnUserLocation()
//    }
//
//    // ---------------------------------------------------
//    // HEADER
//    // ---------------------------------------------------
//    private func setupHeader() {
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        headerView.backgroundColor = UIColor(red: 0.93, green: 0.19, blue: 0.54, alpha: 1)
//        headerView.layer.cornerRadius = 20
//        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//
//        view.addSubview(headerView)
//        NSLayoutConstraint.activate([
//            headerView.topAnchor.constraint(equalTo: view.topAnchor),
//            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            headerView.heightAnchor.constraint(equalToConstant: 110)
//        ])
//
//        // Back button
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.backgroundColor = UIColor(white: 1, alpha: 0.15)
//        backButton.layer.cornerRadius = 22
//        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        backButton.tintColor = .white
//        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        headerView.addSubview(backButton)
//
//        NSLayoutConstraint.activate([
//            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
//            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 10),
//            backButton.heightAnchor.constraint(equalToConstant: 44),
//            backButton.widthAnchor.constraint(equalToConstant: 44)
//        ])
//
//        // Title
//        let title = UILabel()
//        title.text = "Manzilni tanlash"
//        title.font = .systemFont(ofSize: 18, weight: .semibold)
//        title.textColor = .white
//        title.translatesAutoresizingMaskIntoConstraints = false
//        headerView.addSubview(title)
//
//        NSLayoutConstraint.activate([
//            title.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
//            title.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
//        ])
//    }
//
//    // ---------------------------------------------------
//    // MAP
//    // ---------------------------------------------------
//    private func setupMapView() {
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//        mapView.showsUserLocation = true
//        mapView.delegate = self
//
//        view.addSubview(mapView)
//
//        NSLayoutConstraint.activate([
//            mapView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
//            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    // Center pin overlay
//    private func setupCenterPin() {
//        centerPin.translatesAutoresizingMaskIntoConstraints = false
//        centerPin.tintColor = .systemPink
//
//        view.addSubview(centerPin)
//
//        NSLayoutConstraint.activate([
//            centerPin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            centerPin.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
//            centerPin.widthAnchor.constraint(equalToConstant: 40),
//            centerPin.heightAnchor.constraint(equalToConstant: 40)
//        ])
//    }
//
//    // ---------------------------------------------------
//    // ADDRESS LABEL
//    // ---------------------------------------------------
//    private func setupAddressLabel() {
//        addressLabel.translatesAutoresizingMaskIntoConstraints = false
//        addressLabel.font = .systemFont(ofSize: 15, weight: .medium)
//        addressLabel.textAlignment = .center
//        addressLabel.numberOfLines = 2
//        addressLabel.textColor = .darkGray
//
//        view.addSubview(addressLabel)
//
//        NSLayoutConstraint.activate([
//            addressLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            addressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            addressLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
//        ])
//    }
//
//    // ---------------------------------------------------
//    // SAVE BUTTON
//    // ---------------------------------------------------
//    private func setupSaveButton() {
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//        saveButton.setTitle("Manzilni saqlash", for: .normal)
//        saveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
//        saveButton.backgroundColor = .systemPink
//        saveButton.layer.cornerRadius = 28
//        saveButton.setTitleColor(.white, for: .normal)
//        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
//
//        view.addSubview(saveButton)
//
//        NSLayoutConstraint.activate([
//            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
//            saveButton.heightAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//
//    // ---------------------------------------------------
//    // GPS LOCATION BUTTON (FAB button)
//    // ---------------------------------------------------
//    private func setupLocationButton() {
//        locationButton.translatesAutoresizingMaskIntoConstraints = false
//        locationButton.backgroundColor = .white
//        locationButton.layer.cornerRadius = 25
//        locationButton.layer.shadowOpacity = 0.2
//        locationButton.layer.shadowRadius = 6
//        locationButton.layer.shadowOffset = CGSize(width: 0, height: 3)
//        locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
//        locationButton.tintColor = .systemPink
//
//        locationButton.addTarget(self, action: #selector(centerOnUserTapped), for: .touchUpInside)
//
//        view.addSubview(locationButton)
//
//        NSLayoutConstraint.activate([
//            locationButton.widthAnchor.constraint(equalToConstant: 50),
//            locationButton.heightAnchor.constraint(equalToConstant: 50),
//            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            locationButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -20)
//        ])
//    }
//
//    // ---------------------------------------------------
//    // ACTIONS
//    // ---------------------------------------------------
//    @objc private func backTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    @objc private func centerOnUserTapped() {
//        let status = locationManager.authorizationStatus
//
//        switch status {
//        case .denied, .restricted:
//            showLocationDeniedAlert()
//            return
//
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//            return
//
//        case .authorizedWhenInUse, .authorizedAlways:
//            break
//
//        default:
//            break
//        }
//
//        guard let location = mapView.userLocation.location else { return }
//
//        let region = MKCoordinateRegion(
//            center: location.coordinate,
//            latitudinalMeters: 300,
//            longitudinalMeters: 300
//        )
//        mapView.setRegion(region, animated: true)
//    }
//
//    @objc private func saveTapped() {
//        onLocationPicked?(mapView.centerCoordinate, lastAddress)
//        navigationController?.popViewController(animated: true)
//    }
//
//    // ---------------------------------------------------
//    // HELPERS
//    // ---------------------------------------------------
//    private func centerOnUserLocation() {
//        guard let loc = mapView.userLocation.location else { return }
//        let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
//        mapView.setRegion(region, animated: true)
//    }
//
//    private func updateAddressForCenter() {
//        let c = mapView.centerCoordinate
//        geoCoder.cancelGeocode()
//
//        geoCoder.reverseGeocodeLocation(CLLocation(latitude: c.latitude, longitude: c.longitude)) {
//            [weak self] placemarks, _ in
//            guard let self = self else { return }
//
//            if let p = placemarks?.first {
//                let text = [p.thoroughfare, p.subThoroughfare, p.locality]
//                    .compactMap { $0 }
//                    .joined(separator: " ")
//                self.lastAddress = text
//                self.addressLabel.text = text
//            } else {
//                self.lastAddress = nil
//                self.addressLabel.text = "Manzil aniqlanmadi"
//            }
//        }
//    }
//    
//    
//    private func liftPin() {
//        guard !isDraggingMap else { return } // avoid repeating
//        isDraggingMap = true
//        
//        UIView.animate(withDuration: 0.15, animations: {
//            self.centerPin.transform = CGAffineTransform(translationX: 0, y: -20)
//            self.centerPin.alpha = 0.9
//        })
//    }
//
//    private func dropPin() {
//        guard isDraggingMap else { return }
//        isDraggingMap = false
//        
//        UIView.animate(withDuration: 0.2,
//                       delay: 0,
//                       usingSpringWithDamping: 0.5,
//                       initialSpringVelocity: 0.8,
//                       options: .curveEaseOut,
//                       animations: {
//            self.centerPin.transform = .identity
//            self.centerPin.alpha = 1
//        })
//    }
//
//}
//
//// MARK: - DELEGATES
//extension MapSelectionVC: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        dropPin()
//        updateAddressForCenter()
//    }
//    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        liftPin()
//    }
//
//}
//
//extension MapSelectionVC: CLLocationManagerDelegate {
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        if manager.authorizationStatus == .authorizedWhenInUse ||
//            manager.authorizationStatus == .authorizedAlways {
//            mapView.showsUserLocation = true
//        }
//    }
//    
//    func showLocationDeniedAlert() {
//        let alert = UIAlertController(
//            title: "Ruxsat berilmadi",
//            message: "Joylashuvni aniqlash uchun ruxsat bering.",
//            preferredStyle: .alert
//        )
//        
//        alert.addAction(UIAlertAction(title: "Sozlamalarga o'tish", style: .default, handler: { _ in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url)
//            }
//        }))
//        
//        alert.addAction(UIAlertAction(title: "Bekor qilish", style: .cancel))
//
//        present(alert, animated: true)
//    }
//}
//
