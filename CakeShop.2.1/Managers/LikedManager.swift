//
//  LikedManager.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 22/11/25.
//

import Foundation




extension Notification.Name {
    static let likesUpdated = Notification.Name("likesUpdated")
}

class LikeManager {

    static let shared = LikeManager()

    private let key = "liked_cake_ids"

    private init() {
        load()
    }

    private(set) var likedIds: Set<String> = []

    // Load from UserDefaults
    private func load() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            likedIds = Set(saved)
        }
    }

    // Save to UserDefaults
    private func persist() {
        UserDefaults.standard.set(Array(likedIds), forKey: key)
    }

    func isLiked(_ cake: CakeItem) -> Bool {
        likedIds.contains(cake.id)
    }

    func toggleLike(_ cake: CakeItem) {
        if likedIds.contains(cake.id) {
            likedIds.remove(cake.id)
        } else {
            likedIds.insert(cake.id)
        }

        persist()

        NotificationCenter.default.post(name: .likesUpdated, object: nil)
    }

    var likedCakes: [CakeItem] {
        MockData.shared.allCakes.filter { likedIds.contains($0.id) }
    }
}


