//
//  VisualizationViewModel.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation
import Combine

final class VisualizationViewModel: NSObject {
    #warning("TODO: dispatchQueue")
    #warning("TODO: published vs didSet")
    @Published var itemsPerLine: CGFloat = 6 {
        didSet {
            calculator.changeLineNumber(with: Int(itemsPerLine))
        }
    }
    @Published var cellModels: [VictimModel] = []
    
    private var eventPublisher: AnyPublisher<VisualizationViewEvent, Never> = PassthroughSubject<VisualizationViewEvent, Never>().eraseToAnyPublisher()
    private var subscriptions = Set<AnyCancellable>()
    
    private var calculator: EpidemicCalculator
    private var frequency: Int
    
    init(groupSize: Int, factor: Int, frequency: Int) {
        self.calculator = EpidemicCalculator(factor: factor, count: groupSize)
        self.frequency = frequency
        self.cellModels = []
        super.init()
        
        updateSickPopulation()
    }
    
    func updateSickPopulation() {
        cellModels = calculator.getAll().map({VictimModel($0)})
    }
    
    
    func attachEventListener(with subject: AnyPublisher<VisualizationViewEvent, Never>) {
        self.eventPublisher = subject
        eventPublisher
            .sink { [weak self] event in
                switch event {
                case .plusPressed:
                    guard self?.itemsPerLine != 5 else { return }
                    self?.itemsPerLine -= 1
                case .minusPressed:
                    guard self?.itemsPerLine != 20 else { return }
                    self?.itemsPerLine += 1
                case .pause:
                    break
                case .stop:
                    break
                case .wasSelectedAt(let indexPath):
                    self?.calculator.add(with: indexPath.row)
                    self?.updateSickPopulation()
                }
            }
            .store(in: &subscriptions)
    }
}
