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
    
    private let engine: AudioEngine
    let midiStates: MidiControllerStates
    private var voice: CoreVoice
        
    init(
        configuration: Configuration,
        engine: AudioEngine,
        commandPublisher: AnyPublisher<MidiCommand, Never>,
        oscillatorFactory: CoreOscillatorFactory
    ) {
        self.engine = engine
        let midiStates = MidiControllerStates(config: configuration)
        let composer = VoiceComposer(
            sampleRate: engine.sampleRate,
            oscillatorFactory: oscillatorFactory,
            midiStates: midiStates,
            config: configuration)
        self.voice = composer.voice()
        self.midiStates = midiStates
        setupObservables(commandPublisher: commandPublisher)
    }
        
    func start() throws {
        engine.stop()
        engine.sampleSource = voice
        try engine.setup()
        try engine.start()
    }
            
    // MARK: -- handle midi events
    private func setupObservables(commandPublisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = commandPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
        
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(_, let note):
            voice.noteOn(note)
            
        case .noteOff(_, let note):
            voice.noteOff(note)

        case .controlChange(let controllerId, let value):
            midiStates.controlChanged(controllerId, value: value)
        }
    }
/*
    func reconfigure() throws {
        let source = constructSampleSource()
        engine.sampleSource = source
        engine.stop()
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
 */
}

struct VoiceComposer {
    let sampleRate: CoreFloat
    let oscillatorFactory: CoreOscillatorFactory
    let midiStates: MidiControllerStates
    let config: Configuration
    
    func voice() -> CoreVoice {
        let monoVoices = (0..<config.voices)
            .map { _ in
                composeMonoVoice()
            }
        return PolyphonicVoice(voices: monoVoices)
    }
    
    private func composeMonoVoice() -> CoreMonoVoice {
        let mixedOscillator = composeMixedOscillator()
        
        let monoVoice = MonoVoice(
            oscillator: mixedOscillator,
            releaseTime: -0.1
        )
        
        let voiceChain = VoiceChain(voice: monoVoice)
        // TODO: add low pass & envelope filter
        return voiceChain
    }
    
    private func composeMixedOscillator() -> CoreOscillator {
        let weights = midiStates.mixerOscillatorState.storedValue
        let oscillators = (0..<weights.count).map {
            composeDetunedOscillator(index: $0)
        }
        let oscillator = MixedOscillator(
            oscillators: oscillators,
            weights: weights
        )
        midiStates.mixerOscillatorState.addSubscriber(oscillator)
        return oscillator
    }
    
    private func composeDetunedOscillator(index: Int) -> CoreOscillator {
        let inner = composeSelectableOscillator(index: index)
        let oscillator = DetunedOscillator(
            oscillator: inner,
            detune: midiStates.detunedOscillatorStates[index].storedValue
        )
        midiStates.detunedOscillatorStates[index].addSubscriber(oscillator)
        return oscillator
    }
    
    private func composeSelectableOscillator(index: Int) -> CoreOscillator {
        let oscillators = config
            .availableWaveForms
            .map {
                oscillatorFactory.oscillator($0.instance())
            }
        let oscillator = SelectableOscillator(
            oscillators: oscillators,
            current: midiStates.selectableOscillatorStates[index].storedValue
        )
        midiStates.selectableOscillatorStates[index].addSubscriber(oscillator)
        return oscillator
    }
}
