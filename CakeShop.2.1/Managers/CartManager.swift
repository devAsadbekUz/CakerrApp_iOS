//
//  CartManager.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 23/11/25.
//


import Foundation


import Foundation

final class CartManager {

    static let shared = CartManager()

    private(set) var items: [CartLineItem] = []

    var deliveryCost: Int = 25_000

    private init() {}

    // MARK: Add to Cart
    func add(_ cake: CakeItem, serving: Int, unitPrice: Int, quantity: Int = 1) {

        if let index = items.firstIndex(where: { $0.cake.id == cake.id && $0.serving == serving }) {
            items[index].quantity += quantity
        } else {
            let line = CartLineItem(
                cake: cake,
                serving: serving,
                unitPrice: unitPrice,
                quantity: quantity
            )
            items.append(line)
        }

        notify()
    }

    // MARK: Update Quantity
    func setQuantity(for cake: CakeItem, serving: Int, quantity: Int) {

        guard let index = items.firstIndex(where: { $0.cake.id == cake.id && $0.serving == serving }) else { return }

        items[index].quantity = max(1, quantity)
        notify()
    }

    // MARK: Remove
    func remove(_ line: CartLineItem) {
        if let index = items.firstIndex(of: line) {
            items.remove(at: index)
            notify()
        }
    }

    func clear() {
        items.removeAll()
        notify()
    }

    // MARK: Totals
    var subtotal: Int {
        return items.reduce(0) { $0 + ($1.unitPrice * $1.quantity) }
    }

    var total: Int {
        return subtotal + deliveryCost
    }

    // MARK: Notification
    private func notify() {
        NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }
}

extension Notification.Name {
    static let cartUpdated = Notification.Name("cartUpdated")
}
