//
//  AddToCartHelper.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 24/11/25.
//



import UIKit

final class AddToCartHelper {

    static func addToCart(
        from vc: UIViewController,
        cake: CakeItem,
        selectedServing: Int? = nil,
        quantity: Int = 1,
        sourceView: UIView
    ) {

        let serving = selectedServing ?? (cake.servings.first ?? 0)
        let price = cake.pricesByServing[serving] ?? 0

        CartManager.shared.add(cake, serving: serving, unitPrice: price, quantity: quantity)

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        animate(sourceView)
    }

    private static func animate(_ view: UIView) {
        UIView.animate(withDuration: 0.15, animations: {
            view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            view.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                view.transform = .identity
                view.alpha = 1.0
            }
        }
    }
}
