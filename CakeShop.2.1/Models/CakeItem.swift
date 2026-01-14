//
//  CakeItem.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation

struct CakeItem {
    let id: String
    let name: String
    let category: String
    let images: [String]    // multiple images for gallery
    let pricesByServing: [Int: Int]  // price for each size

    let servings: [Int]     // e.g. [2,4,6,8]
    let description: String
    let status: String?     // e.g. "Tayyor"
    
    // Optional customizable properties
    let innerFlavors: [String]?
    let outerCoating: [String]?
    let innerCoating: [String]?
    let toppings: [String]?
}
