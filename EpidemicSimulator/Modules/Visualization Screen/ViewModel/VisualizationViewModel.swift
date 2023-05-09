//
//  VisualizationViewModel.swift
//  EpidemicSimulator
//
//  Created by Someone on 09.05.2023.
//

import Foundation
import Combine

final class VisualizationViewModel: NSObject {
    @Published var parameters: (group: Int, factor: Int, interval: Int)? = nil
    @Published var itemsPerLine: CGFloat = 6
    @Published var cellModels: [VictimModel] = []
    @Published var isRunning: Bool = false
    @Published var isFinished: Bool = true
    @Published var progress: CGFloat = 0.0
    
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
        
        parameters = (groupSize, factor, frequency)
        calculator.delegate = self
    }
    
    func attachEventListener(with subject: AnyPublisher<VisualizationViewEvent, Never>) {
        self.eventPublisher = subject
        eventPublisher
            .sink { [weak self] event in
                switch event {
                case .plusPressed, .minusPressed:
                    self?.changeLineNumber(for: event)
                case .pause:
                    self?.pause()
                case .delete:
                    self?.calculator.pause()
                case .wasSelectedAt(let indexPath):
                    self?.isFinished = false
                    self?.isRunning = true
                    self?.calculator.add(with: indexPath.row)
                }
            }
            .store(in: &subscriptions)
    }
    private func pause() {
        if isRunning {
            calculator.pause()
        } else {
            calculator.run()
        }
        isRunning.toggle()
    }
    
    private func changeLineNumber(for event: VisualizationViewEvent) {

        if event == .minusPressed {
            guard itemsPerLine < 20 else { return }
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
    func update(with items: [Bool], progress: CGFloat) {
        cellModels = items.map({VictimModel($0)})
        self.progress = progress
    }
    
    func finish() {
        isFinished = true
        isRunning = false
    }
}
