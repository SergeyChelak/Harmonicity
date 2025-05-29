//
//  MidiEvent.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

typealias MIDIChannel = UInt8
typealias MIDINoteNumber = UInt8
typealias MIDIVelocity = UInt8

enum MidiEvent {
    case noteOn(MIDIChannel, MIDINote)
    case noteOff(MIDIChannel, MIDINote)
}

struct MIDINote {
    let note: MIDINoteNumber
    let velocity: MIDIVelocity
}
