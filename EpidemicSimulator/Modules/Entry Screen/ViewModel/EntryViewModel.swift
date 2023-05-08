//
//  EntryViewModel.swift
//  EpidemicSimulator
//
//  Created by Someone on 08.05.2023.
//

import Foundation
import Combine

final class EntryViewModel: NSObject {
    var validationPublisher: Published<Bool>.Publisher { $areFieldsValid }
    
    private var groupSize: Int = 0
    private var infectionFactor: Int = 0
    private var calculationFrequency: Int = 0
    
    @Published private var areFieldsValid: Bool = false
    private var eventPublisher: AnyPublisher<EntryViewEvent, Never> = PassthroughSubject<EntryViewEvent, Never>().eraseToAnyPublisher()
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    func attachEventListener(with subject: AnyPublisher<EntryViewEvent, Never>) {
        self.eventPublisher = subject
        eventPublisher
            .sink { [weak self] event in
                switch event {
                case .groupSizeWasSet(let input):
                    self?.groupSize = Int(input) ?? 0
                case .infectionFactorWasSet(let number):
                    self?.infectionFactor = number + 1
                case .calculationFrequencyWasSet(let input):
                    self?.calculationFrequency = Int(input) ?? 0
                case .run:
                    self?.runModulation()
                }
                self?.validateFields()
            }
            .store(in: &subscriptions)
    }
    
    private func validateFields() {
        let validGroupSize = groupSize > 0
        let validInfectionFactor = infectionFactor > 0
        let validFrequency = calculationFrequency > 0
        areFieldsValid = validGroupSize && validFrequency && validInfectionFactor
    }
    
    private func runModulation() {
        print("run")
    }
}
