//
//  MonoVoice.swift
//  Harmonicity
//
//  Created by Sergey on 30.05.2025.
//

import Foundation

class MonoVoice: CoreMonoVoice {
    enum ResetBy {
        case time(CoreFloat)
        case driver(CoreNoteStateDriver)
    }
    
    private let oscillator: CoreOscillator
    private var amplitude: CoreFloat = 0.0
    private(set) var state: NoteState = .idle
    private(set) var noteNumber: MidiNoteNumber = .max
    private let resetBy: ResetBy
    
    init(
        oscillator: CoreOscillator,
        resetBy: ResetBy
    ) {
        self.oscillator = oscillator
        self.resetBy = resetBy
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
        oscillator.setFrequency(freq)
    }
    
    func noteOff(_ note: MidiNote) {
        // don't mute current note if released another one
        guard state.isPlaying && noteNumber == note.note else {
            return
        }
        state = .release
        
        if case(.time(let releaseTime)) = resetBy {
            startResetCountDown(releaseTime)
        }
    }
                
    private func startResetCountDown(_ releaseTime: CoreFloat) {
        let durationMs = Int(releaseTime * 1000)
        DispatchQueue
            .global(qos: .background)
            .asyncAfter(deadline: .now() + .milliseconds(durationMs)) { [weak self] in
                self?.reset()
            }
    }
    
    private func reset() {
        guard state.isReleasing else {
            return
        }
        state = .idle
        self.amplitude = 0
    }
    
    func nextSample() -> CoreFloat {
        if state.isIdle {
            return 0.0
        }
        if case(.driver(let driver)) = resetBy {
            state = driver.noteState()
        }
        
        return amplitude * oscillator.nextSample()
    }
}
