//
//  DetunedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Atomics
import Foundation

final class DetunedOscillator: CoreOscillator {
    let oscillator: CoreOscillator
    private var detune: CoreFloat
    private var pendingDetune: CoreFloat
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    init(oscillator: CoreOscillator, detune: CoreFloat = 0.0) {
        self.oscillator = oscillator
        self.detune = detune
        self.pendingDetune = detune
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        applyUpdate()
        let detunedFrequency = frequency * pow(2.0, detune / 1200.0) // 1200 cents per octave
        oscillator.setFrequency(detunedFrequency)
    }
    
    // TODO: update also could be applied here but omitted for simplicity
    func nextSample() -> CoreFloat {
        oscillator.nextSample()
    }
    
    private func applyUpdate() {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            detune = pendingDetune
        }
    }
}

extension DetunedOscillator: CoreMidiControlChangeHandler {
    func controlChanged(_ control: MidiControllerId, value: MidiValue) {
        // TODO: fix this
        pendingDetune = CoreFloat(value) - CoreFloat(MidiValue.max / 2)
        needsUpdate.store(true, ordering: .releasing)
    }
}
