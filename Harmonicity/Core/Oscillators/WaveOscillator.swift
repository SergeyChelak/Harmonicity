//
//  WaveOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class WaveOscillator: CoreOscillator {
    private let sampleRate: CoreFloat
    private let waveForm: CoreWaveForm
    
    private var phase: CoreFloat = 0.0
    private var delta: CoreFloat = 0.0
    
    // cache
    private let range: Range<CoreFloat>
    
    init(sampleRate: CoreFloat, waveForm: CoreWaveForm) {
        self.sampleRate = sampleRate
        self.waveForm = waveForm
        self.range = waveForm.phaseRange()
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        // TODO: commented for single voice that produces clip after frequency change
        self.phase = range.lowerBound
        self.delta = range.length * frequency / sampleRate
    }
    
    func nextSample() -> CoreFloat {
        let sample = waveForm.value(phase)
        phase += delta
        if phase >= range.upperBound {
            phase = range.lowerBound
        }
        return sample
    }
}
