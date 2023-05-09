//
//  EpidemicCalculator.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation
#warning("FIXIT: lines problem")
#warning("TODO: stop feature")
#warning("FIXIT: out of range problem")

// MARK: - EpidemicCalculatorDelegate

protocol EpidemicCalculatorDelegate: AnyObject {
    func update(with items: [Bool])
}

// MARK: - EpidemicCalculatorDescription
protocol EpidemicCalculatorDescription {
    var delegate: EpidemicCalculatorDelegate? { get set }
    func run()
    func changeLineNumber(with value: Int)
    func add(with index: Int)
    func pause()
}

// MARK: - EpidemicCalculator

final class EpidemicCalculator: EpidemicCalculatorDescription {
    private let factor: Int
    private let count: Int
    private let interval: Int
    private var itemsPerLine: Int = 6
    private var sickItems: Set<Int> = []
    private var newSickItems: Set<Int> = []
    
    private var isRunning: Bool = false
    
    weak var delegate: EpidemicCalculatorDelegate?
    
    private let queue = DispatchQueue(label: "com.ulGord.EpidemicSimulator.calculator.queue", qos: .background, attributes: .concurrent)
    
    init(factor: Int, count: Int, interval: Int) {
        self.factor = factor
        self.count = count
        self.interval = interval
        
        start()
    }
    
    private func start() {
        DispatchQueue.main.async { [weak self] in
            self?.update()
        }
    }
    
    func pause() {
        isRunning = false
    }
    
    func run() {
        isRunning = true
        step()
    }
    
    private func step() {
        guard checkForHealthy() else {
            print(sickItems.sorted(by: <))
            return }
        queue.asyncAfter(deadline: .now() + .seconds(interval), execute: {[weak self] in
            self?.calculate()
            self?.step()
        })
    }
    
    private func update() {
        delegate?.update(with: getAll())
    }
    
    private func getAll() -> [Bool] {
        return (0...count - 1).map { sickItems.contains($0) }
    }
    
    private func calculate() {
        let group = DispatchGroup()
        sickItems.forEach { item in
            group.enter()
            self.infectNeighbors(for: item) {
                group.leave()
            }
        }
        reset()
        group.notify(queue: .main) {[weak self] in
            self?.update()
        }
    }
    
    func changeLineNumber(with value: Int) {
        itemsPerLine = value
    }
    
    func add(with index: Int) {
        if !isRunning { run() }
        
        queue.async(flags: .barrier, execute: {[weak self] in
            self?.sickItems.insert(index)
            DispatchQueue.main.async(execute: {
                self?.update()
            })
        })
    }
    
    private func checkForHealthy() -> Bool {
        return sickItems.count <= count
    }

    private func infectNeighbors(for index: Int, _ completion: @escaping () -> Void) {
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
        completion()
    }
    
    private func reset() {
        sickItems = sickItems.union(newSickItems)
        newSickItems = []
    }
}
