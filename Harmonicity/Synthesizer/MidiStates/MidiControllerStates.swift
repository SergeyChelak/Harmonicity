//
//  MidiControllerStates.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

final class MidiControllerStates {
    let selectableOscillatorStates: [SelectableOscillatorState]
    let detunedOscillatorStates: [DetunedOscillatorState]
    let mixerOscillatorState: MixerOscillatorState
    let envelopeFilterState: EnvelopeFilterState
    
    init(config: Configuration) {
        // ----
        selectableOscillatorStates = config.selectableOscillatorControl.map {
            SelectableOscillatorState(
                initial: 0,
                maxValue: config.availableWaveForms.count,
                controllerId: $0
            )
        }
        // ----
        detunedOscillatorStates = config.detunedOscillatorControl.map {
            DetunedOscillatorState(
                initial: 0.0,
                controllerId: $0
            )
        }
        // ----
        let mixerOscillatorControls = config.mixerOscillatorControls
        let defaultMixWeights = [CoreFloat].init(
            repeating: 1.0,
            count: config.oscillatorsPerVoice
        )
        mixerOscillatorState = MixerOscillatorState(
            initial: defaultMixWeights,
            channel: mixerOscillatorControls.channel,
            controllers: mixerOscillatorControls.controllers
        )
        
        // ---
        let envelopeFilterControls = config.envelopeFilterControls
        envelopeFilterState = EnvelopeFilterState(
            initial: .init(),
            channel: envelopeFilterControls.channel,
            attackCtrl: envelopeFilterControls.controllers[0],
            decayCtrl: envelopeFilterControls.controllers[1],
            sustainCtrl: envelopeFilterControls.controllers[2],
            releaseCtrl: envelopeFilterControls.controllers[3]
        )
    }
}

extension MidiControllerStates: CoreMidiControlChangeHandler {
    func controlChanged(_ controllerId: MidiControllerId, value: MidiValue) {
        selectableOscillatorStates.forEach {
            $0.controlChanged(controllerId, value: value)
        }
        detunedOscillatorStates.forEach {
            $0.controlChanged(controllerId, value: value)
        }
        mixerOscillatorState.controlChanged(controllerId, value: value)
    }
}
