//
//  Configuration.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Foundation
import AVFAudio

final class Configuration {
    private enum ControlOffset: MidiChannel {
        case selectable = 1
        case detune = 10
        case mixer = 20
        case envelope = 30
        case reverb = 40
    }
    
    private let channel: MidiChannel
    
    init(channel: MidiChannel) {
        self.channel = channel
    }
    
    var oscillatorsPerVoice: Int {
        3
    }
    
    var availableWaveForms: [WaveForm] {
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
            ControlOffset.mixer.rawValue + MidiController($0)
        }
        return MixerControllerIds(
            channel: channel,
            controllers: controllers
        )
    }
    
    var envelopeFilterControls: MixerControllerIds {
        let controllers = (0..<4).map {
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
    
    var reverbControls: MixerControllerIds {
        return MixerControllerIds(
            channel: channel,
            controllers: [
                ControlOffset.reverb.rawValue,
                ControlOffset.reverb.rawValue + 1,
            ]
        )
    }
    
    var reverbPresets: [AVAudioUnitReverbPreset] {
        [
            .smallRoom,
            .mediumRoom,
            .largeRoom,
            .mediumHall,
            .largeHall,
            .plate,
            .mediumChamber,
            .largeChamber,
            .cathedral,
            .largeRoom2,
            .mediumHall2,
            .mediumHall3,
            .largeHall2
        ]
    }
    
    struct MixerControllerIds {
        let channel: MidiChannel
        let controllers: [MidiController]
    }
    
    enum WaveForm {
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

}
