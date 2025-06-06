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
    private let configuration: SynthesizerConfiguration
    
    init(
        configuration: SynthesizerConfiguration,
        engine: AudioEngine,
        commandPublisher: AnyPublisher<MidiCommand, Never>,
        oscillatorFactory: CoreOscillatorFactory
    ) {
        self.configuration = configuration
        self.engine = engine
        self.midiEventBus = MidiCommandBus(
            publisher: commandPublisher
        )
        self.oscillatorFactory = oscillatorFactory
    }
    
    func reconfigure() {
        guard let source = constructSampleSource() else {
            return
        }
        engine?.sampleSource = source
    }
    
    private func constructSampleSource() -> CoreSampleSource? {
        guard let sampleRate = engine?.sampleRate else {
            return nil
        }
        let monoVoices = (0..<configuration.voices).map {
            _ in constructMonoVoice(sampleRate)
        }
        let voice = PolyphonicVoice(voices: monoVoices)
        midiEventBus.register(voice, on: nil)
        return voice
    }

    
    private func constructMonoVoice(_ sampleRate: CoreFloat) -> CoreMonoVoice {
        let mixedOscillator = MixedOscillator()
        for _ in 0..<configuration.rootOscillatorsCount {
            let voice = voiceOscillator()
            
            let detunedOscillator = DetunedOscillator(
                oscillator: voice
            )
                                    
            _ = mixedOscillator.addSource(detunedOscillator)
        }
        
        let monoVoice = MonoVoice(
            oscillator: mixedOscillator,
            releaseTime: -0.1
        )
        let lowPassFilter = LowPassFilter(
            sampleRate: sampleRate,
            cutoffFrequency: 10_000
        )
        
        let envelopeFilter = envelopeFilter(sampleRate)
        
        let voiceChain = VoiceChain(voice: monoVoice)
        voiceChain.chain(lowPassFilter)
        voiceChain.chain(envelopeFilter)
        return voiceChain
    }
    
    private func voiceOscillator() -> CoreOscillator {
        let oscillators = configuration.waveForms
            .map {
                oscillatorFactory.oscillator($0.instance())
            }
        let oscillator = SelectableOscillator(
            oscillators: oscillators,
            current: 0
        )
        return oscillator
    }
    
    private func envelopeFilter(
        _ sampleRate: CoreFloat
    ) -> ADSRFilter {
        let envelopeFilter = ADSRFilter(
            sampleRate: sampleRate,
            releaseTime: 0.01
        )
        return envelopeFilter
    }
}
