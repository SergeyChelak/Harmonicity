//
//  MixedVoice.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class MixedVoice: CoreVoice {
    private let oscillators: [CoreOscillator]
    private(set) var amplitude: Float = 0.0
    private var note: MIDINoteNumber = 0
    
    init(oscillators: [CoreOscillator]) {
        self.oscillators = oscillators
    }
    
    func play(_ data: MIDINote) {
        let velocity = Float(data.velocity) / 127
        // don't mute current note if released another one
        if velocity == 0 && note != data.note {
            return
        }
        self.amplitude = velocity
        self.note = data.note
        let freq = 440.0 * pow(2.0, (Float(data.note) - 69.0) / 12.0)
        print("Voice frequency: \(freq)")
        oscillators.forEach {
            $0.setFrequency(freq)
        }
    }
    
    func nextSample() -> Sample {
        amplitude * oscillators
            .map { $0.nextSample() }
            .reduce(0.0) { $0 + $1 } / Float(oscillators.count)
    }
}
