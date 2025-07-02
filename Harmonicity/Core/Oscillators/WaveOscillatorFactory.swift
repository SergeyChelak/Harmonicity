//
//  WaveOscillatorFactory.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class WaveOscillatorFactory: CoreOscillatorFactory {
    private let sampleRate: CoreFloat
    private let phaseGenerator: PhaseGenerator
    
    init(
        sampleRate: CoreFloat,
        phaseGenerator: PhaseGenerator
    ) {
        self.sampleRate = sampleRate
        self.phaseGenerator = phaseGenerator
    }
    
    func oscillator(_ waveForm: any CoreWaveForm) -> any CoreOscillator {
        WaveOscillator(
            sampleRate: sampleRate,
            waveForm: waveForm,
            phaseGenerator: phaseGenerator
        )
    }
}
