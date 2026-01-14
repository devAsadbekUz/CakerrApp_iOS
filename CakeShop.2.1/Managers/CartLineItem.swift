//
//  CartLineItem.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 25/11/25.
//


//
//  CartLineItem.swift
//  CakeShop.2.1
//

import Foundation

//
//  CartLineItem.swift
//  CakeShop.2.1
//

import Foundation

struct CartLineItem: Equatable {

    let cake: CakeItem
    let serving: Int        // selected porsiya
    let unitPrice: Int      // price for selected serving
    var quantity: Int       // mutable

    static func ==(lhs: CartLineItem, rhs: CartLineItem) -> Bool {
        return lhs.cake.id == rhs.cake.id && lhs.serving == rhs.serving
    }
}

