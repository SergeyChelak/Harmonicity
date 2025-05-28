//
//  Core.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

typealias Sample = Float
typealias Frequency = Float

protocol CoreProcessor {
    func process(x: Sample) -> Sample
}

protocol CoreOscillator {
    func setFrequency(_ frequency: Frequency)
    func nextSample() -> Sample
}

protocol CoreWaveForm {
    func value(_ x: Float) -> Float
    func period() -> Range<Float>
}

extension CoreWaveForm {
    func periodDuration() -> Float {
        let p = self.period()
        return p.upperBound - p.lowerBound
    }
}

protocol CoreOscillatorFactory {
    func oscillator(_ waveForm: CoreWaveForm) -> CoreOscillator
}
