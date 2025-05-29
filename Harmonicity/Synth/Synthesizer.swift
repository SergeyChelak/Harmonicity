//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import AVFoundation
import Foundation

func composeSynthesizer(
    midiCommandCenter: MidiCommandCenter,
    oscillatorFactory: CoreOscillatorFactory,
    engine: AudioEngine
) -> Synthesizer {
    let midiEventBus = MidiCommandBus(
        publisher: midiCommandCenter.publisher
    )
    let voice = composeVoice(
        sampleRate: engine.sampleRate,
        factory: oscillatorFactory
    )
    midiEventBus.add(voice)
    engine.sampleSource = voice
    
    return Synthesizer(
        midiEventBus: midiEventBus
    )
}

func composeVoice(sampleRate: Float) -> CoreVoice {
    let factory = WaveOscillatorFactory(sampleRate: sampleRate)
    return composeVoice(
        sampleRate: sampleRate,
        factory: factory
    )
}

func composeVoice(
    sampleRate: Float,
    factory: CoreOscillatorFactory
) -> CoreVoice {
    let sineOscillator = factory.oscillator(SineWaveForm())
    
    let multiVoice = MixedVoice(oscillators: [
        factory.oscillator(SquareWaveForm()),
        DetunedOscillator(
            oscillator: sineOscillator,
            detune: 15
        ),
        DetunedOscillator(
            oscillator: sineOscillator,
            detune: -15
        )
    ])
    
//    let envelopeFilter = ADSRFilter(sampleRate: sampleRate)
    
    let voiceChain = VoiceChain(voice: multiVoice)
    voiceChain.chain(LowPassFilter(sampleRate: sampleRate, cutoffFrequency: 10_000))
//    voiceChain.chain(envelopeFilter)
    voiceChain.chain(ClipFilter(minimum: -1.0, maximum: 1.0))
    return voiceChain
}


struct Synthesizer {
    let midiEventBus: MidiCommandBus
}
