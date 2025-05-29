//
//  DetunedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class DetunedOscillator: CoreOscillator {
    let oscillator: CoreOscillator
    
    var detune: Float
    
    init(oscillator: CoreOscillator, detune: Float = 0.0) {
        self.oscillator = oscillator
        self.detune = detune
    }
    
    func setFrequency(_ frequency: Frequency) {
        let detunedFrequency = frequency * pow(2.0, detune / 1200.0) // 1200 cents per octave
        oscillator.setFrequency(detunedFrequency)
    }
    
    func nextSample() -> Sample {
        oscillator.nextSample()
    }
}
