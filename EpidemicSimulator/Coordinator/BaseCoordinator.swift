//
//  BaseCoordinator.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import UIKit

protocol BaseCoordinatorDescription: Coordinator {
    func toVisualizationScreen(groupScreen: Int, infectionFactor: Int, calculationFrequency: Int)
    func toEntryScreen()
}

class BaseCoordinator: NSObject, BaseCoordinatorDescription {
    weak var parentCoordinator: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        toEntryScreen()
    }
    
    func toVisualizationScreen(groupScreen: Int,
                               infectionFactor: Int,
                               calculationFrequency: Int
    ) {
        let viewModel = VisualizationViewModel(groupSize: groupScreen,
                                               factor: infectionFactor,
                                               frequency: calculationFrequency,
                                               coordinator: self)
        let viewController = VisualizationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func toEntryScreen() {
        navigationController.popViewController(animated: true)
        let viewModel = EntryViewModel(coordinator: self)
        let viewController = EntryViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
