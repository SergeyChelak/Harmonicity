//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import Combine
import Foundation

struct Synthesizer {
    private let midiEventBus: MidiCommandBus
    private let oscillatorFactory: CoreOscillatorFactory
    private weak var engine: AudioEngine?
    
    init(
        engine: AudioEngine,
        commandPublisher: AnyPublisher<MidiCommand, Never>,
        oscillatorFactory: CoreOscillatorFactory
    ) {
        self.engine = engine
        self.midiEventBus = MidiCommandBus(
            publisher: commandPublisher
        )
        self.oscillatorFactory = oscillatorFactory
    }
    
    func constructSampleSource() -> CoreSampleSource? {
        guard let sampleRate = engine?.sampleRate else {
            return nil
        }
        let squareOscillator = oscillatorFactory.oscillator(SawtoothWaveForm())
        
        let sineOscillator = oscillatorFactory.oscillator(SineWaveForm())
        
        let multiVoice = MixedVoice(
            oscillators: [
                squareOscillator,
                DetunedOscillator(
                    oscillator: sineOscillator,
                    detune: 5
                ),
                DetunedOscillator(
                    oscillator: sineOscillator,
                    detune: -5
                )
            ],
            releaseTime: -0.1)
        
        let lowPassFilter = LowPassFilter(
            sampleRate: sampleRate,
            cutoffFrequency: 10_000
        )
        let envelopeFilter = ADSRFilter(
            sampleRate: sampleRate,
//            attackTime: 0.1,
            releaseTime: 0.3
        )
        
        let voiceChain = VoiceChain(voice: multiVoice)
        voiceChain.chain(lowPassFilter)
        voiceChain.chain(envelopeFilter)
//        voiceChain.chain(AbsFilter())
        voiceChain.chain(ClipFilter(minimum: -1, maximum: 1))

        midiEventBus.add(voiceChain)
        midiEventBus.add(lowPassFilter)
        midiEventBus.add(envelopeFilter)

        return voiceChain
    }
    
    func reconfigure() {
        guard let source = constructSampleSource() else {
            return
        }
        engine?.sampleSource = source
    }
}
