//
//  Voice.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

final class MultiVoice: CoreVoice {
    private let oscillators: [CoreOscillator]
    private(set) var amplitude: Float = 0.0
    private var note: MIDINoteNumber = 0
    
    init(oscillators: [CoreOscillator]) {
        self.oscillators = oscillators
    }
    
    func play(_ data: MIDINote) {
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
