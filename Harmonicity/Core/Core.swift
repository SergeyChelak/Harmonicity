//
//  Core.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

typealias CoreFloat = Double

protocol CoreProcessor {
    func process(_ sample: CoreFloat) -> CoreFloat
}

protocol CoreSampleSource {
    func nextSample() -> CoreFloat
}

protocol CoreOscillator: CoreSampleSource {
    func setFrequency(_ frequency: CoreFloat)
}

protocol CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat
    func phaseRange() -> Range<CoreFloat>
}

extension CoreWaveForm {
    func phaseDuration() -> CoreFloat {
        let p = self.phaseRange()
        return p.upperBound - p.lowerBound
    }
}

protocol CoreOscillatorFactory {
    func oscillator(_ waveForm: CoreWaveForm) -> CoreOscillator
}

protocol CoreVoice: CoreSampleSource, CoreMIDINoteHandler {
    var isPlaying: Bool { get }
}

protocol CoreMIDINoteHandler {
    func noteOn(_ note: MidiNote)
    func noteOff(_ note: MidiNote)
}
