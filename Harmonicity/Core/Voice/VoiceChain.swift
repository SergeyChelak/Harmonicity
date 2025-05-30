//
//  VoiceChain.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class VoiceChain<T: CoreVoice>: CoreVoice {
    let voice: T
    
    private var processChain: [CoreProcessor] = []
    
    init(voice: T) {
        self.voice = voice
    }
        
    func chain(_ processor: CoreProcessor) {
        processChain.append(processor)
    }
    
    var state: VoiceState {
        voice.state
    }
    
    func canPlay(_ note: MidiNote) -> Bool {
        voice.canPlay(note)
    }
    
    func noteOn(_ note: MidiNote) {
        voice.noteOn(note)
        noteHandlers()
            .forEach { $0.noteOn(note) }
    }
    
    func noteOff(_ note: MidiNote) {
        voice.noteOff(note)
        noteHandlers()
            .forEach { $0.noteOff(note) }
    }
    
    func nextSample() -> CoreFloat {
        var sample = voice.nextSample()
        for processor in processChain {
            sample = processor.process(sample)
        }
        return sample
    }
    
    private func noteHandlers() -> [CoreMIDINoteHandler] {
        processChain
            .compactMap {
                $0 as? CoreMIDINoteHandler
            }
    }
}

extension VoiceChain: CoreMonoVoice where T: CoreMonoVoice {
    var noteNumber: MidiNoteNumber {
        voice.noteNumber
    }
}
