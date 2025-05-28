//
//  WaveOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class WaveOscillator: CoreOscillator {
    private let sampleRate: Float
    private let waveForm: CoreWaveForm
    
    private var phase: Float = 0.0
    private var delta: Float = 0.0
    
    // cache
    private let range: Range<Float>
    
    init(sampleRate: Float, waveForm: CoreWaveForm) {
        self.sampleRate = sampleRate
        self.waveForm = waveForm
        self.range = waveForm.period()
    }
    
    func setFrequency(_ frequency: Frequency) {
        self.phase = 0.0
        self.delta = range.length * frequency / sampleRate
    }
    
    func nextSample() -> Sample {
        let sample = waveForm.value(phase)
        phase += delta
        if phase >= range.upperBound {
            phase = range.lowerBound
        }
        return sample
    }
}
