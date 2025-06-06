//
//  SelectableOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 03.06.2025.
//

import Atomics
import Combine
import Foundation

class SelectableOscillator: CoreOscillator {
    let id = UUID()
    private let oscillators: [CoreOscillator]
    private var current: Int
    private var pendingCurrent: Int
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    private let subject: CurrentValueSubject<SelectedIndex, Never>
    
    init(oscillators: [CoreOscillator], current: Int) {
        assert(!oscillators.isEmpty, "Oscillators list can't be empty")
        self.oscillators = oscillators
        self.current = 0
        self.pendingCurrent = 0
        
        self.subject = CurrentValueSubject(
            SelectedIndex(sender: id, midiValue: 0, value: current)
        )
    }
    
    var publisher: AnyPublisher<SelectedIndex, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        applyUpdate()
        oscillators[current].setFrequency(frequency)
    }
    
    func nextSample() -> CoreFloat {
        applyUpdate()
        return oscillators[current].nextSample()
    }
    
    private func applyUpdate() {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            current = pendingCurrent
        }
    }
}

extension SelectableOscillator: CoreMidiControlChangeHandler {
    func controlChanged(_ control: MidiControllerId, value: MidiValue) {
        pendingCurrent = Int(value) % oscillators.count
        subject.send(
            SelectedIndex(sender: id, midiValue: value, value: pendingCurrent)
        )
        needsUpdate.store(true, ordering: .releasing)
    }
}

struct SelectedIndex {
    let sender: UUID
    let midiValue: MidiValue
    let value: Int
}
