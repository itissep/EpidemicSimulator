//
//  VisualizationEvent.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation

enum VisualizationViewEvent: Equatable {
    case plusPressed
    case minusPressed
    case pause
    case delete
    case wasSelectedAt(IndexPath)
}
