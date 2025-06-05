//
//  SynthesizerConfiguration.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Foundation

struct SynthesizerConfiguration {
    var voices: Int { 8 }
    
    var rootOscillatorsCount: Int { 3 }
    
    var rootOscillatorSelectControllers: [MidiControllerId] {
        [1, 2, 3].controllerId(on: virtualMidiChannel)
    }
    
    var rootOscillatorDetuneControllers: [MidiControllerId] {
        [20, 21, 22].controllerId(on: virtualMidiChannel)
    }
    
    var rootOscillatorsMixerControllers: [MidiControllerId] {
        [10, 11, 12].controllerId(on: virtualMidiChannel)
    }
    
    var envelopeFilterController: EnvelopeMidiControls {
        EnvelopeMidiControls(
            channel: virtualMidiChannel,
            parameters: [
                (.attack, 30),
                (.decay, 31),
                (.sustain, 32),
                (.release, 33)
            ]
        )
    }
}

struct MidiControllerId {
    let channel: MidiChannel?
    let controller: MidiController
}

struct EnvelopeMidiControls {
    let channel: MidiChannel
    let parameters: [(ADSRFilter.Parameter, MidiController)]
}

fileprivate extension Array where Element == MidiController {
    func controllerId(on channel: MidiChannel?) -> [MidiControllerId] {
        self.map {
            MidiControllerId(
                channel: virtualMidiChannel,
                controller: $0
            )
        }
    }
}
