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
                                                                     .font: Styles.mainFont])
    }
    
    private func layout() {
        self.backgroundColor = Styles.Color.mustardWithAlpha
        self.keyboardType = .numberPad
        self.layer.cornerRadius = Styles.cornerRadius
        self.layer.masksToBounds = true
        
        self.font = Styles.mainFont
        self.textColor = Styles.Color.yellow
    }
}
