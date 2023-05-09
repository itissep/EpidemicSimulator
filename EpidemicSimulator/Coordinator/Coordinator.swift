//
//  Coordinator.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var children: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}

extension Coordinator {
    func childDidFinish(_ coordinator: Coordinator) {
        for (index, child) in children.enumerated() where child === coordinator {
                children.remove(at: index)
                break
        }
    }
}
