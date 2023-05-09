//
//  CustomTextField.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

final class CustomTextField: UITextField {
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds: CGRect) -> CGRect {
        return forBounds.insetBy(dx: Styles.padding , dy: Styles.padding)
     }

     override func editingRect(forBounds: CGRect) -> CGRect {
         return forBounds.insetBy(dx: Styles.padding , dy: Styles.padding)
     }

     override func placeholderRect(forBounds: CGRect) -> CGRect {
         return forBounds.insetBy(dx: Styles.padding, dy: Styles.padding)
     }
    
    func setPlaceholder(_ placeholderString: String) {
        self.attributedPlaceholder = NSAttributedString(string: placeholderString,
                                                        attributes: [.foregroundColor: Styles.Color.mustard ?? .yellow,
                                                                     .font: Styles.inputFont])
    }
    
    private func layout() {
        self.backgroundColor = Styles.Color.mustardWithAlpha
        self.keyboardType = .phonePad
        self.layer.cornerRadius = Styles.cornerRadius
        self.layer.masksToBounds = true
        self.tintColor = Styles.Color.yellow
        
        self.font = Styles.inputFont
        self.textColor = Styles.Color.yellow
    }
}
