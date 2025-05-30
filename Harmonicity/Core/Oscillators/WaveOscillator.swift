//
//  WaveOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation
import Dispatch
import Atomics

class WaveOscillator: CoreOscillator {
    private let sampleRate: CoreFloat
    private let waveForm: CoreWaveForm
    
    private var phase: CoreFloat = 0.0
    private var delta: CoreFloat = 0.0
    
    private var isLocked = ManagedAtomic<Bool>(false)
    private var sample: CoreFloat = 0.0
    
    // cache
    private let range: Range<CoreFloat>
    
    init(sampleRate: CoreFloat, waveForm: CoreWaveForm) {
        self.sampleRate = sampleRate
        self.waveForm = waveForm
        self.range = waveForm.phaseRange()
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        isLocked.store(true, ordering: .relaxed)
        let newDelta = range.length * frequency / sampleRate
        if abs(newDelta - delta) > 1e-10 {
            self.phase = range.lowerBound
            self.delta = newDelta
        }
        isLocked.store(false, ordering: .relaxed)
    }
    
    func nextSample() -> CoreFloat {
        if isLocked.load(ordering: .relaxed) {
            return sample
        }
        sample = waveForm.value(phase)
        phase += delta
        if phase >= range.upperBound {
            phase = range.lowerBound
        }
        return sample
    }
}
