//
//  DetunedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class DetunedOscillator: CoreOscillator {
    let oscillator: CoreOscillator
    
    var detune: CoreFloat
    
    init(oscillator: CoreOscillator, detune: CoreFloat = 0.0) {
        self.oscillator = oscillator
        self.detune = detune
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        let detunedFrequency = frequency * pow(2.0, detune / 1200.0) // 1200 cents per octave
        oscillator.setFrequency(detunedFrequency)
    }
    
    func nextSample() -> CoreFloat {
        oscillator.nextSample()
    }
}
