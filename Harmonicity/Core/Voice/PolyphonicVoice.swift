//
//  PolyphonicVoice.swift
//  Harmonicity
//
//  Created by Sergey on 30.05.2025.
//

import Foundation

final class PolyphonicVoice: CoreVoice {
    private static let log = logger(category: "PolyphonicVoice")
    
    private let voices: [CoreMonoVoice]
    
    init(voices: [CoreMonoVoice]) {
        self.voices = voices
    }
    
    var state: NoteState {
        .idle
    }
    
    func canPlay(_ note: MidiNote) -> Bool {
        voices.reduce(false) { $0 || $1.canPlay(note) }
    }
        
    func nextSample() -> CoreFloat {
        var output = 0.0
        for voice in voices {
            let sample = voice.nextSample()
            output += sample
        }
        return output
    }
    
    func noteOn(_ note: MidiNote) {
        for voice in voices where voice.canPlay(note) {
            voice.noteOn(note)
            return
        }
        for voice in voices where voice.state.isReleasing {
            voice.noteOn(note)
            return
        }
        Self.log.warning("free voice not found")
    }
    
    func noteOff(_ note: MidiNote) {
        for voice in voices {
            voice.noteOff(note)
        }
    }
}
