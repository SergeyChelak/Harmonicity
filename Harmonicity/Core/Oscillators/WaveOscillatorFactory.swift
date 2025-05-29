//
//  WaveOscillatorFactory.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class WaveOscillatorFactory: CoreOscillatorFactory {
    private let sampleRate: CoreFloat
    
    init(sampleRate: CoreFloat) {
        self.sampleRate = sampleRate
    }
    
    func oscillator(_ waveForm: any CoreWaveForm) -> any CoreOscillator {
        WaveOscillator(
            sampleRate: sampleRate,
            waveForm: waveForm
        )
    }
}
