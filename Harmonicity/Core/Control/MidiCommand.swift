//
//  MidiEvent.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

typealias MidiChannel = UInt8
typealias MidiNoteNumber = UInt8
typealias MidiVelocity = UInt8

enum MidiCommand {
    case noteOn(MidiChannel, MidiNote)
    case noteOff(MidiChannel, MidiNote)
}

struct MidiNote {
    let note: MidiNoteNumber
    let velocity: MidiVelocity
}
