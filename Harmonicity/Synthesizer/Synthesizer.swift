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
        let monoVoices = (0..<configuration.voices).map { _ in constructMonoVoice(sampleRate) }
        let voice = PolyphonicVoice(voices: monoVoices)
        let voiceChain = VoiceChain(voice: voice)
        midiEventBus.register(voiceChain, on: nil)
        return voiceChain
    }

    
    private func constructMonoVoice(_ sampleRate: CoreFloat) -> CoreMonoVoice {
        let mixedOscillator = MixedOscillator()
        for oscillator in 0..<configuration.rootOscillatorsCount {
            let selectMidiControllerId = configuration.rootOscillatorSelectControllers[oscillator]
            let voice = voiceOscillator(criteria: selectMidiControllerId)
            
            let detunedOscillator = DetunedOscillator(
                oscillator: voice
            )
            let detuneMidiControllerId = configuration.rootOscillatorDetuneControllers[oscillator]
            midiEventBus.register(
                detunedOscillator,
                criteria: detuneMidiControllerId
            )
                        
            let id = mixedOscillator.addSource(detunedOscillator)
            let mixerMidiControllerCriteria = configuration.rootOscillatorsMixerControllers[oscillator]
            mixedOscillator.bind(criteria: mixerMidiControllerCriteria, source: id)
            midiEventBus.register(
                mixedOscillator,
                criteria: mixerMidiControllerCriteria
            )
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
    
    private func voiceOscillator(
        criteria: MidiControllerIdCriteria
    ) -> CoreOscillator {
        let oscillators = [
            oscillatorFactory.oscillator(SineWaveForm()),
            oscillatorFactory.oscillator(SawtoothWaveForm()),
            oscillatorFactory.oscillator(SquareWaveForm()),
            oscillatorFactory.oscillator(TriangleWaveForm())
        ]
        let oscillator = SelectableOscillator(
            oscillators: oscillators,
            current: 0
        )
        // register select oscillator control
        midiEventBus.register(oscillator, criteria: criteria)
        return oscillator
    }
    
    private func envelopeFilter(
        _ sampleRate: CoreFloat
    ) -> ADSRFilter {
        let envelopeFilter = ADSRFilter(
            sampleRate: sampleRate,
            releaseTime: 0.01
        )
        let envelopeFilterController = configuration.envelopeFilterController
        for (param, controllerId) in envelopeFilterController.parameters {
            let criteria = MidiControllerIdCriteria(
                channel: envelopeFilterController.channel,
                controller: controllerId
            )
            envelopeFilter.bind(
                criteria: criteria,
                parameter: param
            )
            midiEventBus.register(
                envelopeFilter,
                criteria: criteria
            )
        }
        return envelopeFilter
    }
}
