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
    
    private func setupMixedOscillator() -> CoreOscillator {
        let mixedOscillator = MixedOscillator()
        for oscillator in 0..<configuration.rootOscillatorsCount {
            let selectMidiControllerId = configuration.rootOscillatorSelectControllers[oscillator]
            let voice = voiceOscillator(
                midiChannel: selectMidiControllerId.channel,
                controller: selectMidiControllerId.controller
            )
            
            let detunedOscillator = DetunedOscillator(
                oscillator: voice
            )
            let detuneMidiControllerId = configuration.rootOscillatorDetuneControllers[oscillator]
            midiEventBus.add(
                detunedOscillator,
                controller: detuneMidiControllerId.controller,
                on: detuneMidiControllerId.channel
            )
            
            let mixerMidiControllerId = configuration.rootOscillatorsMixerControllers[oscillator]
            // TODO: while it mapped 1 to 1, there is no issue
            let id = mixedOscillator.addSource(detunedOscillator)
            mixedOscillator.bind(controller:mixerMidiControllerId.controller, source: id)
            midiEventBus.add(
                mixedOscillator,
                controller: mixerMidiControllerId.controller,
                on: mixerMidiControllerId.channel
            )
        }
        return mixedOscillator
    }
    
    private func voiceOscillator(
        midiChannel: MidiChannel?,
        controller: MidiController
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
        midiEventBus.add(oscillator, controller: controller, on: midiChannel)
        return oscillator
    }
    
    private func constructSampleSource() -> CoreSampleSource? {
        guard let sampleRate = engine?.sampleRate else {
            return nil
        }
        let monoVoices = (0..<configuration.voices).map { _ in constructMonoVoice(sampleRate) }
        let voice = PolyphonicVoice(voices: monoVoices)
        let voiceChain = VoiceChain(voice: voice)
        midiEventBus.add(voiceChain, on: 0)
        return voiceChain
    }
    
    private func constructMonoVoice(_ sampleRate: CoreFloat) -> CoreMonoVoice {
        let mainOscillator = setupMixedOscillator()
        
        let monoVoice = MonoVoice(
            oscillator: mainOscillator,
            releaseTime: -0.1
        )
        
        let lowPassFilter = LowPassFilter(
            sampleRate: sampleRate,
            cutoffFrequency: 10_000
        )
        let envelopeFilter = ADSRFilter(
            sampleRate: sampleRate,
            releaseTime: 0.01
        )
        
        let voiceChain = VoiceChain(voice: monoVoice)
        voiceChain.chain(lowPassFilter)
        voiceChain.chain(envelopeFilter)
        return voiceChain
    }
}
