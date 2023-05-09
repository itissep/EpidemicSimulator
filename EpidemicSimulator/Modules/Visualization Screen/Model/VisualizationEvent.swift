//
//  VisualizationEvent.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation

enum VisualizationViewEvent {
    case plusPressed
    case minusPressed
    case pause
    case stop
    case wasSelectedAt(IndexPath)
}
