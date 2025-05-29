//
//  VoiceChain.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class VoiceChain<T: CoreVoice>: CoreVoice {
    let voice: T
    private var sample: CoreFloat = 0.0
    
    private var processChain: [CoreProcessor] = []
    
    init(voice: T) {
        self.voice = voice
    }
        
    func chain(_ processor: CoreProcessor) {
        processChain.append(processor)
    }
    
    var isPlaying: Bool {
        abs(sample) < 1e-10
    }
    
    func noteOn(_ note: MidiNote) {
        voice.noteOn(note)
    }
    
    func noteOff(_ note: MidiNote) {
        voice.noteOff(note)
    }
    
    func nextSample() -> CoreFloat {
        sample = voice.nextSample()
        for processor in processChain {
            sample = processor.process(sample)
        }
        return sample
    }
}

extension VoiceChain: CoreMonoVoice where T: CoreMonoVoice {
    var noteNumber: MidiNoteNumber {
        voice.noteNumber
    }
}
