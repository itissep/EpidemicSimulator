//
//  UIView.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { viewToAdd in
            self.addSubview(viewToAdd)
            viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
