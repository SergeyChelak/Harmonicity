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
    
    var waveForms: [KnownWaveForm] {
        [.sine, .sawtooth, .triangle, .square]
    }
    
    var rootOscillatorSelectControllers: [MidiControllerIdCriteria] {
        [1, 2, 3].controllerId(on: virtualMidiChannel)
    }
    
    var rootOscillatorDetuneControllers: [MidiControllerIdCriteria] {
        [20, 21, 22].controllerId(on: virtualMidiChannel)
    }
    
    var rootOscillatorsMixerControllers: [MidiControllerIdCriteria] {
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

enum KnownWaveForm {
    case sine, square, triangle, sawtooth
    
    func instance() -> CoreWaveForm {
        switch self {
        case .sine:
            Self.sineWaveForm
        case .square:
            Self.squareWaveForm
        case .triangle:
            Self.triangleWaveForm
        case .sawtooth:
            Self.sawtoothWaveForm
        }
    }
    
    private static let sineWaveForm = SineWaveForm()
    private static let squareWaveForm = SquareWaveForm()
    private static let triangleWaveForm = TriangleWaveForm()
    private static let sawtoothWaveForm = SawtoothWaveForm()
}


struct EnvelopeMidiControls {
    let channel: MidiChannel
    let parameters: [(ADSRFilter.Parameter, MidiController)]
}

fileprivate extension Array where Element == MidiController {
    func controllerId(on channel: MidiChannel?) -> [MidiControllerIdCriteria] {
        self.map {
            MidiControllerIdCriteria(
                channel: virtualMidiChannel,
                controller: $0
            )
        }
    }
}
