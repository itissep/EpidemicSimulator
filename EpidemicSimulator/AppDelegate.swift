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
    var coordinator: BaseCoordinatorDescription?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        let navController = UINavigationController()
        coordinator = BaseCoordinator(navigationController: navController)
        coordinator?.start()
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

