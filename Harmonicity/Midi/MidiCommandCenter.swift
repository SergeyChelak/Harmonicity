//
//  MidiCommandCenter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Combine
import Foundation

final class MidiCommandCenter {
    private let eventPublisher = PassthroughSubject<MidiCommand, Never>()
    
    var publisher: AnyPublisher<MidiCommand, Never> {
        eventPublisher.eraseToAnyPublisher()
    }
    
    func on(note: MidiNoteNumber, velocity: MidiVelocity, channel: MidiChannel) {
        let value = MidiNote(
            note: note,
            velocity: velocity
        )
        eventPublisher.send(.noteOn(channel, value))
    }
    
    func off(note: MidiNoteNumber, velocity: MidiVelocity, channel: MidiChannel) {
        let value = MidiNote(
            note: note,
            velocity: velocity
        )
        eventPublisher.send(.noteOff(channel, value))
    }
}
