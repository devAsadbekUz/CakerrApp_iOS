//
//  Order.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 12/3/25.
//

import Foundation

import CoreLocation

struct Order {
    let address: String
    let coordinate: CLLocationCoordinate2D
    let date: Date
    let timeSlot: String
    let paymentMethod: String
    let note: String?

    let items: [OrderItem]
}
