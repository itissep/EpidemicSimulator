//
//  VictimModel.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation


struct VictimModel: Hashable {
    let id: String
    let isSick: Bool
    
    init(_ isSick: Bool = false) {
        self.id = UUID().uuidString
        self.isSick = isSick
    }
}
