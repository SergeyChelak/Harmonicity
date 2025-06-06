//
//  SelectableOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 03.06.2025.
//

import Atomics
import Foundation

class SelectableOscillator: CoreOscillator {
    private let oscillators: [CoreOscillator]
    private var current: Int
    private var pendingCurrent: Int
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    init(oscillators: [CoreOscillator], current: Int) {
        assert(!oscillators.isEmpty, "Oscillators list can't be empty")
        self.oscillators = oscillators
        self.current = 0
        self.pendingCurrent = 0
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
    
    func setCurrent(_ index: Int) {
        pendingCurrent = index
        needsUpdate.store(true, ordering: .releasing)
    }
}
