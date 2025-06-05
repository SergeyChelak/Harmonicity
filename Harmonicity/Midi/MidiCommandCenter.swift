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
    
    func on(note: MidiValue, velocity: MidiValue, channel: MidiChannel) {
        let value = MidiNote(
            note: note,
            velocity: velocity
        )
        eventPublisher.send(.noteOn(channel, value))
    }
    
    func off(note: MidiValue, velocity: MidiValue, channel: MidiChannel) {
        let value = MidiNote(
            note: note,
            velocity: velocity
        )
        eventPublisher.send(.noteOff(channel, value))
    }
    
    func controlChange(control: MidiValue, value: MidiValue, channel: MidiChannel) {
        print("ch: \(channel) ctrl: \(control) value: \(value)")
        let controlId = MidiControllerId(
            channel: channel,
            controller: control
        )
        eventPublisher.send(.controlChange(controlId, value))
    }
}
