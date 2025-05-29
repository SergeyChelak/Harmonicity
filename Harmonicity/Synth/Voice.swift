//
//  Voice.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

final class SimpleVoice: CoreVoice {
    private let oscillator: CoreOscillator
    private var velocity: Float = 0.0
    
    private var note: MIDINote = 0
    
    init(oscillator: CoreOscillator) {
        self.oscillator = oscillator
    }
    
    func play(_ data: NoteData) {
        let velocity = Float(data.velocity) / 127
        // don't mute current note if released another one
        if velocity == 0 && note != data.note {
            return
        }
        self.velocity = velocity
        self.note = data.note
        let freq = 440.0 * pow(2.0, (Float(data.note) - 69.0) / 12.0)
        print("Voice frequency: \(freq)")
        oscillator.setFrequency(freq)
    }
    
    func nextSample() -> Sample {
        velocity * oscillator.nextSample()
    }
}


final class Oscillator {
    var waveform: Waveform
    var weight: Float
    
    init(waveform: Waveform, weight: Float = 1.0) {
        self.waveform = waveform
        self.weight = weight
    }
}


final class Voice {
    private var phase: Float = 0.0
    private var oscillators: [Oscillator]
    
    private(set) var velocity: Float = 0.0
    private var delta: Float = 0.0
    
    var sampleRate: Float = 0.0
    
    var note: MIDINote = 0
    
    init(oscillators: [Oscillator]) {
        self.oscillators = oscillators
    }
    
    func nextSample() -> Float {
        guard sampleRate > 0.0 else {
            return 0
        }
        
        let (sum, totalWeight) = oscillators
            .map {
                (
                    $0.weight * velocity * $0.waveform.value(phase: phase),
                    $0.weight
                )
            }
            .reduce((0, 0)) { acc, val in
                (acc.0 + val.0, acc.1 + val.1)
            }
                
        phase += delta
        if phase >= 2.0 * .pi {
            phase -= 2.0 * .pi
        }
        
        return sum / totalWeight
    }
    
    func play(frequency: Float, velocity: Float) {
        self.phase = 0
        self.velocity = velocity
        self.delta = 2.0 * .pi * frequency / sampleRate
    }
}
