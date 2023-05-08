//
//  EntryViewEvent.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import Foundation

enum EntryViewEvent {
    case groupSizeWasSet(String)
    case infectionFactorWasSet(Int)
    case calculationFrequencyWasSet(String)
    case run
}
