//
//  MixedVoice.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class MixedVoice: CoreVoice {
    private let oscillators: [CoreOscillator]
    private var amplitude: CoreFloat = 0.0
    private var note: MidiNoteNumber = .max
    private(set) var isPlaying = false
    private var releaseTime: CoreFloat
    
    init(
        oscillators: [CoreOscillator],
        releaseTime: CoreFloat = 0.0
    ) {
        self.oscillators = oscillators
        self.releaseTime = releaseTime
    }
    
    func noteOn(_ note: MidiNote) {
        isPlaying = true
        let velocity = CoreFloat(note.velocity) / 127
        self.amplitude = velocity
        self.note = note.note
        let freq = 440.0 * pow(2.0, (CoreFloat(note.note) - 69.0) / 12.0)
        print("Voice frequency: \(freq)")
        oscillators.forEach {
            $0.setFrequency(freq)
        }
    }
    
    func noteOff(_ note: MidiNote) {
        // don't mute current note if released another one
        guard self.note == note.note else {
            return
        }
        isPlaying = false
        // sound forever
        if releaseTime < 0.0 {
            return
        }
        if releaseTime == 0.0 {
            self.amplitude = 0
            return
        }
        let durationMs = Int(releaseTime * 1000)
        DispatchQueue
            .global(qos: .background)
            .asyncAfter(deadline: .now() + .milliseconds(durationMs)) { [weak self] in
                self?.amplitude = 0
            }
    }
        
    func nextSample() -> CoreFloat {
        amplitude * oscillators
            .map { $0.nextSample() }
            .reduce(0.0) { $0 + $1 } / CoreFloat(oscillators.count)
    }
}
