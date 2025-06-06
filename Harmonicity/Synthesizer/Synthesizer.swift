//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import Combine
import Foundation

final class Synthesizer {
    private var cancellable: AnyCancellable?
    
    private let oscillatorFactory: CoreOscillatorFactory
    private let engine: AudioEngine
    private let configuration: SynthesizerConfiguration
    
    private var voice: CoreVoice?
    private var controlSubscribers: [CoreMidiControlChangeHandler] = []
    
    init(
        configuration: SynthesizerConfiguration,
        engine: AudioEngine,
        commandPublisher: AnyPublisher<MidiCommand, Never>,
        oscillatorFactory: CoreOscillatorFactory
    ) {
        self.configuration = configuration
        self.engine = engine
        self.oscillatorFactory = oscillatorFactory
        
        cancellable = commandPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
    
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(_, let note):
            voice?.noteOn(note)
            
        case .noteOff(_, let note):
            voice?.noteOff(note)

        case .controlChange(let controllerId, let value):
            controlSubscribers.forEach {
                $0.controlChanged(controllerId, value: value)
            }
        }
    }
    
    func configure() {
    }
    
    func reconfigure() throws {
        engine.stop()
        let source = constructSampleSource()
        engine.sampleSource = source
        try engine.setup()
        try engine.start()
    }
    
    private func constructSampleSource() -> CoreSampleSource {
        let sampleRate = engine.sampleRate
        let monoVoices = (0..<configuration.voices).map {
            _ in constructMonoVoice(sampleRate)
        }
        let voice = PolyphonicVoice(voices: monoVoices)
        self.voice = voice
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
            envelope: .init()
        )
        return envelopeFilter
    }
}
