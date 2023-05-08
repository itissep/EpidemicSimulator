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
        let viewModel = EntryViewModel()
//        let vc = EntryViewController(viewModel: viewModel)
        let vc = VisualizationViewController()
        let navController = UINavigationController(rootViewController: vc)
        
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

