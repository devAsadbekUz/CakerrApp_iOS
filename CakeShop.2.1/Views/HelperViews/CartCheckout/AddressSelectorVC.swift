//
//  AddressSelectorVC.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 28/11/25.
//

import Foundation


// AddressSelectorVC.swift
// Search + results. Present modally from CheckoutVC.

import UIKit
import MapKit
import CoreLocation

final class AddressSelectorVC: UIViewController {

    // callback
    var onAddressSelected: ((_ coordinate: CLLocationCoordinate2D, _ address: String) -> Void)?

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private var results: [MKMapItem] = []

    private let findOnMapButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Find on map", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return b
    }()
    
    private let locateMeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .white
        b.layer.cornerRadius = 25
        b.layer.shadowOpacity = 0.25
        b.layer.shadowRadius = 6
        b.layer.shadowOffset = CGSize(width: 0, height: 3)

        let icon = UIImage(systemName: "location.fill")
        b.setImage(icon, for: .normal)
        b.tintColor = .systemBlue
        return b
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFloatingButton()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Manzil qidirish"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))

        setupSearch()
        setupTable()
        setupFooter()
    }
    
    private func setupFloatingButton() {
        view.addSubview(locateMeButton)

        NSLayoutConstraint.activate([
            locateMeButton.widthAnchor.constraint(equalToConstant: 50),
            locateMeButton.heightAnchor.constraint(equalToConstant: 50),
            locateMeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // ❗ FIX: anchor to safe area, NOT to findOnMapButton
            locateMeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])

        locateMeButton.addTarget(self, action: #selector(locationsButtonTapped), for: .touchUpInside)
    }

    
    @objc private func locationsButtonTapped() {
        let mapVC = MapSelectionVC()
        mapVC.pickCurrentLocationImmediately = true

        mapVC.onLocationPicked = { [weak self] coord, address in
            guard let self = self else { return }
            self.onAddressSelected?(coord, address ?? "Manzil")
            self.dismiss(animated: true)
        }

        navigationController?.pushViewController(mapVC, animated: true)
    }



    private func setupSearch() {
        searchBar.placeholder = "Manzil yoki kafe qidirish"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -64)
        ])
    }

    private func setupFooter() {
        findOnMapButton.translatesAutoresizingMaskIntoConstraints = false
        findOnMapButton.addTarget(self, action: #selector(findOnMapTapped), for: .touchUpInside)
        view.addSubview(findOnMapButton)

        NSLayoutConstraint.activate([
            findOnMapButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            findOnMapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            findOnMapButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            findOnMapButton.heightAnchor.constraint(equalToConstant: 48)
        ])

        findOnMapButton.layer.cornerRadius = 12
        findOnMapButton.backgroundColor = .systemBlue
        findOnMapButton.setTitleColor(.white, for: .normal)
    }

    @objc private func closeTapped() { dismiss(animated: true) }

    @objc private func findOnMapTapped() {
        let mapVC = MapSelectionVC()
        // when map selection finishes, we propagate result
        mapVC.onLocationPicked = { [weak self] coord, address in
            guard let self = self else { return }
            self.onAddressSelected?(coord, address ?? "Manzil")
            self.dismiss(animated: true)
        }
        navigationController?.pushViewController(mapVC, animated: true)
    }

    private func search(query: String) {
        results.removeAll()
        tableView.reloadData()

        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        let search = MKLocalSearch(request: req)
        search.start { [weak self] resp, error in
            guard let self = self else { return }
            if let items = resp?.mapItems {
                self.results = items
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }
    }
}

extension AddressSelectorVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let q = searchBar.text, !q.isEmpty else { return }
        search(query: q)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // quick live search if desired; comment out if noisy
        if searchText.count >= 3 {
            search(query: searchText)
        } else if searchText.isEmpty {
            results.removeAll()
            tableView.reloadData()
        }
    }
}

extension AddressSelectorVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { results.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = results[indexPath.row]
        let c = tv.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var text = item.name ?? ""
        if let adr = item.placemark.title { text += " — \(adr)" }
        c.textLabel?.text = text
        c.textLabel?.numberOfLines = 2
        return c
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = results[indexPath.row]
        let coord = item.placemark.coordinate
        let title = [item.name, item.placemark.thoroughfare, item.placemark.locality]
            .compactMap { $0 }
            .joined(separator: ", ")
        onAddressSelected?(coord, title)
        dismiss(animated: true)
    }
}
