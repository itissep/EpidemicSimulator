//
//  Collection.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import Foundation

extension Collection {
    func choose(_ n: Int) -> ArraySlice<Element> { shuffled().prefix(n) }
}

