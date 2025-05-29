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
    func process(_ sample: Sample) -> Sample
    func reset()
}

extension CoreProcessor {
    func reset() { }
}

protocol CoreSampleSource {
    func nextSample() -> Sample
}

protocol CoreOscillator: CoreSampleSource {
    func setFrequency(_ frequency: Frequency)
}

protocol CoreWaveForm {
    func value(_ x: Float) -> Float
    func phaseRange() -> Range<Float>
}

extension CoreWaveForm {
    func phaseDuration() -> Float {
        let p = self.phaseRange()
        return p.upperBound - p.lowerBound
    }
}

protocol CoreOscillatorFactory {
    func oscillator(_ waveForm: CoreWaveForm) -> CoreOscillator
}

protocol CoreVoice: CoreSampleSource {
    func play(_ note: MIDINote)
    var amplitude: Float { get }
}
