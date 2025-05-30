//
//  MixedVoice.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class MixedVoice: CoreMonoVoice {
    private let oscillators: [CoreOscillator]
    private var amplitude: CoreFloat = 0.0
    
    private(set) var state: VoiceState = .idle
    private(set) var noteNumber: MidiNoteNumber = .max
    
    private var releaseTime: CoreFloat
    
    init(
        oscillators: [CoreOscillator],
        releaseTime: CoreFloat = 0.0
    ) {
        self.oscillators = oscillators
        self.releaseTime = releaseTime
    }
    
    func canPlay(_ note: MidiNote) -> Bool {
        noteNumber == note.note || state.isIdle
    }
    
    func noteOn(_ note: MidiNote) {
        state = .play
        let velocity = CoreFloat(note.velocity) / 127
        self.amplitude = velocity
        self.noteNumber = note.note
        let freq = 440.0 * pow(2.0, (CoreFloat(note.note) - 69.0) / 12.0)
//        print("Voice frequency: \(freq)")
        oscillators.forEach {
            $0.setFrequency(freq)
        }
    }
    
    func noteOff(_ note: MidiNote) {
        // don't mute current note if released another one
        guard state.isPlaying && noteNumber == note.note else {
            return
        }
        state = .release
    
        // sound forever
        if releaseTime < 0.0 {
            return
        }
        let durationMs = Int(releaseTime * 1000)
        DispatchQueue
            .global(qos: .background)
            .asyncAfter(deadline: .now() + .milliseconds(durationMs)) { [weak self] in
                self?.reset()
            }
    }
    
    private func reset() {
        state = .idle
        self.amplitude = 0
    }
        
    func nextSample() -> CoreFloat {
        if state.isIdle {
            return 0.0
        }
        return amplitude * oscillators
            .map { $0.nextSample() }
            .reduce(0.0) { $0 + $1 } / CoreFloat(oscillators.count)
    }
}
