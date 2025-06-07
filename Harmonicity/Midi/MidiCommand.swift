//
//  MidiEvent.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

typealias MidiValue = UInt8
typealias MidiChannel = MidiValue
typealias MidiNoteNumber = MidiValue
typealias MidiVelocity = MidiValue
typealias MidiController = MidiValue

enum MidiCommand {
    case noteOn(MidiChannel, MidiNote)
    case noteOff(MidiChannel, MidiNote)
    case controlChange(MidiControllerId, MidiValue)
}

struct MidiControllerId: Hashable {
    let channel: MidiChannel
    let controller: MidiController
}

struct MidiNote {
    let note: MidiValue
    let velocity: MidiValue
}

let virtualMidiChannel: MidiChannel = MidiChannel.max
let maxMidiValue: MidiValue = 127
