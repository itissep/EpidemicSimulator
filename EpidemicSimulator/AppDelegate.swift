//
//  AppDelegate.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        
        let navController = UINavigationController(rootViewController: ViewController())
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

