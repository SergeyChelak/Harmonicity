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
            attackControlId: MidiControllerId(channel: virtualMidiChannel, controller: 30),
            decayControlId: MidiControllerId(channel: virtualMidiChannel, controller: 31),
            sustainControlId: MidiControllerId(channel: virtualMidiChannel, controller: 32),
            releaseControlId: MidiControllerId(channel: virtualMidiChannel, controller: 33)
        )
    }
}

struct MidiControllerId {
    let channel: MidiChannel?
    let controller: MidiController
}

struct EnvelopeMidiControls {
    let attackControlId: MidiControllerId
    let decayControlId: MidiControllerId
    let sustainControlId: MidiControllerId
    let releaseControlId: MidiControllerId
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
