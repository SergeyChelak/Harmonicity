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
    
    var amplitude: Float {
        voice.amplitude
    }
    
    func chain(_ processor: CoreProcessor) {
        processChain.append(processor)
    }
    
    func play(_ data: MIDINote) {
        processChain.forEach { $0.reset() }
        voice.play(data)
    }
    
    func nextSample() -> Sample {
        guard amplitude != 0.0 else {
            return 0.0
        }
        var sample = voice.nextSample()
        for processor in processChain {
            sample = processor.process(sample)
        }
        return sample
    }
}
