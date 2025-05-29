//
//  MixedVoice.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class MixedVoice: CoreVoice {
    private let oscillators: [CoreOscillator]
    private var amplitude: Float = 0.0
    private var note: MidiNoteNumber = .max
    private(set) var isPlaying = false
    private var releaseTime: Float
    
    init(
        oscillators: [CoreOscillator],
        releaseTime: Float = 0.0
    ) {
        self.oscillators = oscillators
        self.releaseTime = releaseTime
    }
    
    func noteOn(_ note: MidiNote) {
        isPlaying = true
        let velocity = Float(note.velocity) / 127
        self.amplitude = velocity
        self.note = note.note
        let freq = 440.0 * pow(2.0, (Float(note.note) - 69.0) / 12.0)
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
        }
        let durationMs = Int(releaseTime * 1000)
        DispatchQueue
            .global(qos: .background)
            .asyncAfter(deadline: .now() + .seconds(durationMs)) { [weak self] in
                self?.amplitude = 0
            }
    }
    
    func play(_ data: MidiNote) {
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
