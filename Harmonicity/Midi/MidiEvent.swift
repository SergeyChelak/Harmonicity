//
//  MidiEvent.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

typealias MIDIChannel = UInt8
typealias MIDINote = UInt8
typealias MIDIVelocity = UInt8

enum MidiEvent {
    case note(NoteData)
}

struct NoteData {
    let channel: MIDIChannel
    let note: MIDINote
    let velocity: MIDIVelocity
}
