//
//  PolyphonicVoice.swift
//  Harmonicity
//
//  Created by Sergey on 30.05.2025.
//

import Foundation

final class PolyphonicVoice : CoreVoice {
    private let voices: [CoreMonoVoice]
    
    init(voices: [CoreMonoVoice]) {
        self.voices = voices
    }
    
    var state: NoteState {
        fatalError()
    }
    
    func canPlay(_ note: MidiNote) -> Bool {
        fatalError()
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
        print("[WARN] free voice not found")
    }
    
    func noteOff(_ note: MidiNote) {
        for voice in voices {
            voice.noteOff(note)
        }
    }
}
