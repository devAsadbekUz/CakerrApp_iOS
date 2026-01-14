//
//  OrderItem.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 12/3/25.
//

import Foundation


struct OrderItem {
    let id: String
    let name: String
    let category: String

    let quantity: Int
    let serving: Int
    let unitPrice: Int
    let totalPrice: Int
    let images: [String]

    let type: CakeOrderType
    let standardOptions: StandardCakeOptions?
    let customOptions: CustomCakeOptions?
}

enum CakeOrderType {
    case standard
    case custom
}

