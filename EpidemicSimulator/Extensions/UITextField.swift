//
//  UITextField.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit
import Combine

extension UITextField {
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text  ?? "" }
            .eraseToAnyPublisher()
    }
}
