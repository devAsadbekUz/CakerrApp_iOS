//
//  AppDelegate.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)

        // ❗ Correct: Tab bar is the root, NOT inside a navigation controller
        let tabBar = CustomTabBarController()
        window?.rootViewController = tabBar
        window?.makeKeyAndVisible()

        return true
        
    
    }



}

