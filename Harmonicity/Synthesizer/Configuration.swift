//
//  Configuration.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Foundation

final class Configuration {
    enum ControlOffset: MidiChannel {
        case selectable = 1
        case detune = 10
        case mixer = 20
        case envelope = 30
    }
    
    private let channel: MidiChannel
    
    init(channel: MidiChannel) {
        self.channel = channel
    }
    
    var oscillatorsPerVoice: Int {
        3
    }
    
    var availableWaveForms: [KnownWaveForm] {
        [.sine, .sawtooth, .triangle, .square]
    }
    
    var selectableOscillatorControl: [MidiControllerId] {
        (0..<oscillatorsPerVoice).map {
            MidiControllerId(
                channel: channel,
                controller: MidiChannel($0) + ControlOffset.selectable.rawValue
            )
        }
    }
    
    var detunedOscillatorControl: [MidiControllerId] {
        (0..<oscillatorsPerVoice).map {
            MidiControllerId(
                channel: channel,
                controller: MidiChannel($0) + ControlOffset.detune.rawValue
            )
        }
    }
    
    var mixerOscillatorControls: MixerControllerIds {
        let controllers = (0..<oscillatorsPerVoice).map {
            ControlOffset.envelope.rawValue + MidiController($0)
        }
        return MixerControllerIds(
            channel: channel,
            controllers: controllers
        )
    }
    
    var voices: Int {
        8
    }
    
    struct MixerControllerIds {
        let channel: MidiChannel
        let controllers: [MidiController]
    }
}

enum KnownWaveForm {
    case sine, square, triangle, sawtooth
    
    private static let sineWaveForm = SineWaveForm()
    private static let squareWaveForm = SquareWaveForm()
    private static let triangleWaveForm = TriangleWaveForm()
    private static let sawtoothWaveForm = SawtoothWaveForm()
    
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
}
