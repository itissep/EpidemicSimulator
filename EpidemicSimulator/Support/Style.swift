//
//  File.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import UIKit

struct Styles {
    struct Color {
        static let black = UIColor(named: "BlackColor")
        static let mustard = UIColor(named: "MustardColor")
        static let mustardWithAlpha = mustard?.withAlphaComponent(0.5)
        static let yellow = UIColor(named: "YellowColor")
    }
    
    static let titleFont = UIFont.systemFont(ofSize: 40, weight: .bold)
    static let inputFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    static let padding: CGFloat = 16.0
    static let cornerRadius: CGFloat = 10.0
}
