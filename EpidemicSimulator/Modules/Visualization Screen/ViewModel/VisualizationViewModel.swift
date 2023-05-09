//
//  VisualizationViewModel.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation
import Combine

final class VisualizationViewModel: NSObject {
    @Published var itemsPerLine: CGFloat = 6
    @Published var cellModels: [VictimModel] = []
    
    private var eventPublisher: AnyPublisher<VisualizationViewEvent, Never> = PassthroughSubject<VisualizationViewEvent, Never>().eraseToAnyPublisher()
    private var subscriptions = Set<AnyCancellable>()
    
    private var calculator: EpidemicCalculatorDescription
    private var frequency: Int
    private let coordinator: BaseCoordinatorDescription
    
    init(groupSize: Int,
         factor: Int,
         frequency: Int,
         coordinator: BaseCoordinatorDescription
    ) {
        self.calculator = EpidemicCalculator(factor: factor, count: groupSize, interval: frequency)
        self.frequency = frequency
        self.cellModels = []
        self.coordinator = coordinator
        super.init()
        
        calculator.delegate = self
    }
    
    func attachEventListener(with subject: AnyPublisher<VisualizationViewEvent, Never>) {
        self.eventPublisher = subject
        eventPublisher
            .sink { [weak self] event in
                switch event {
                case .plusPressed, .minusPressed:
                    self?.changeLineNumber(for: event)
                case .pause, .delete:
                    self?.calculator.pause()
                case .wasSelectedAt(let indexPath):
                    self?.calculator.add(with: indexPath.row)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func changeLineNumber(for event: VisualizationViewEvent) {

        if event == .minusPressed {
            guard itemsPerLine < 21 else { return }
            itemsPerLine += 1
        } else {
            guard itemsPerLine > 5 else { return }
            itemsPerLine -= 1
        }
        calculator.changeLineNumber(with: Int(itemsPerLine))
    }
}

// MARK: - EpidemicCalculatorDelegate

extension VisualizationViewModel: EpidemicCalculatorDelegate {
    func update(with items: [Bool]) {
        cellModels = items.map({VictimModel($0)})
    }
}
