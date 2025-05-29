//
//  VoiceChain.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class VoiceChain: CoreVoice {
    let voice: CoreVoice
    
    private var processChain: [CoreProcessor] = []
    
    init(voice: CoreVoice) {
        self.voice = voice
    }
        
    func chain(_ processor: CoreProcessor) {
        processChain.append(processor)
    }
    
    var isPlaying: Bool {
        voice.isPlaying
    }
    
    func noteOn(_ note: MidiNote) {
        voice.noteOn(note)
    }
    
    func noteOff(_ note: MidiNote) {
        voice.noteOff(note)
    }
    
    func nextSample() -> CoreFloat {
        var sample = voice.nextSample()
        for processor in processChain {
            sample = processor.process(sample)
        }
        return sample
    }
}
