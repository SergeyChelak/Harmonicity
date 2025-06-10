//
//  VoiceComposer.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

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
        let envelopeFilter = composeEnvelopeFilter()
        
        let monoVoice = MonoVoice(
            oscillator: mixedOscillator,
            resetBy: .driver(envelopeFilter)
        )
        
        let voiceChain = VoiceChain(voice: monoVoice)

//        let lowPassFilter = LowPassFilter(
//            sampleRate: sampleRate,
//            cutoffFrequency: 10_000
//        )
//        voiceChain.chain(lowPassFilter)
        
        voiceChain.chain(envelopeFilter)
        
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
    
    private func composeEnvelopeFilter() -> CoreEnvelopeFilter {
        let envelopeFilter = ADSRFilter(
            sampleRate: sampleRate,
            envelope: midiStates.envelopeFilterState.storedValue
        )
        midiStates.envelopeFilterState.addSubscriber(envelopeFilter)
        return envelopeFilter
    }
}
