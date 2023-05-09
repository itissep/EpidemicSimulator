//
//  EpidemicCalculator.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation

final class EpidemicCalculator {
    let factor: Int
    let count: Int
    var itemsPerLine: Int = 6
    var sickItems: Set<Int> = []
    var newSickItems: Set<Int> = []
    
    
    init(factor: Int, count: Int) {
        self.factor = factor
        self.count = count
    }
    
    func getAll() -> [Bool] {
        calculate()
        return (0...count - 1).map { sickItems.contains($0) }
    }
    
    func calculate(){
        sickItems.forEach { item in
            infectNeighbors(for: item)
        }
        reset()
    }
    
    func changeLineNumber(with value: Int) {
        print(value)
        itemsPerLine = value
    }
    
    func add(with index: Int) {
        sickItems.insert(index)
    }

    private func infectNeighbors(for index: Int) {
        var array: [Int] = Array(repeating: -1, count: 9)
        array[0] = index - itemsPerLine - 1
        array[1] = index - itemsPerLine
        array[2] = index - itemsPerLine + 1
        
        array[3] = index - 1
        array[4] = index
        array[5] = index + 1
        
        array[6] = index + itemsPerLine - 1
        array[7] = index + itemsPerLine
        array[8] = index + itemsPerLine + 1
        
        if index % itemsPerLine == 0 {
            array[0] = -1
            array[3] = -1
            array[6] = -1
        }
        
        if (index + 1) % itemsPerLine == 0 {
            array[2] = -1
            array[5] = -1
            array[8] = -1
        }
        
        if index - itemsPerLine <= 0 {
            array[0] = -1
            array[1] = -1
            array[2] = -1
        }
        
        if index - itemsPerLine >= count {
            array[6] = -1
            array[7] = -1
            array[8] = -1
        }
        
        var set: Set<Int> = []
        array.forEach { neighbor in
            guard neighbor != -1 else { return }
            guard !sickItems.contains(neighbor) else { return }
            set.insert(neighbor)
        }
        
        set.choose(factor).forEach { neighbor in
            newSickItems.insert(neighbor)
        }
    }
    
    private func reset() {
        sickItems = sickItems.union(newSickItems)
        newSickItems = []
    }

}
