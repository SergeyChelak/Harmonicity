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
    private let voices: Int
    
    init(
        voices: Int,
        engine: AudioEngine,
        commandPublisher: AnyPublisher<MidiCommand, Never>,
        oscillatorFactory: CoreOscillatorFactory
    ) {
        self.voices = voices
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
        let monoVoices = (0..<voices).map { _ in constructMonoVoice(sampleRate) }
        let voice = PolyphonicVoice(voices: monoVoices)
        let voiceChain = VoiceChain(voice: voice)
        midiEventBus.add(voiceChain)
        return voiceChain
    }
    
    private func constructMonoVoice(_ sampleRate: CoreFloat) -> CoreMonoVoice {
        let sawtoothOscillator = oscillatorFactory.oscillator(SawtoothWaveForm())
        let sineOscillator = oscillatorFactory.oscillator(SineWaveForm())
        let squareOscillator = oscillatorFactory.oscillator(SquareWaveForm())
        
        let multiVoice = MixedVoice(
            oscillators: [
                sawtoothOscillator,
                DetunedOscillator(
                    oscillator: sineOscillator,
                    detune: 5
                ),
                DetunedOscillator(
                    oscillator: squareOscillator,
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
            releaseTime: 0.3
        )
        
        let voiceChain = VoiceChain(voice: multiVoice)
        voiceChain.chain(lowPassFilter)
        voiceChain.chain(envelopeFilter)
        return voiceChain
    }
    
    func reconfigure() {
        guard let source = constructSampleSource() else {
            return
        }
        engine?.sampleSource = source
    }
}
