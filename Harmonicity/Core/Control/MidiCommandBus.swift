//
//  MidiCommandBus.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation
import Combine

class MidiCommandBus {
    private var cancellable: AnyCancellable?
    
    private struct NoteHandler {
        let channel: MidiChannel?
        let handler: WeakRef<CoreMidiNoteHandler>
    }
    
    private struct ControlChangeHandler {
        let criteria: MidiControllerIdCriteria
        let handler: WeakRef<CoreMidiControlChangeHandler>
    }

    private var noteSubscribers: [NoteHandler] = []
    private var controlSubscribers: [ControlChangeHandler] = []
    
    init(publisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = publisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
    
    func register(_ handler: CoreMidiNoteHandler, on channel: MidiChannel?) {
        let subscriber = NoteHandler(
            channel: channel,
            handler: WeakRef(value: handler)
        )
        noteSubscribers.append(subscriber)
    }
    
    func register(
        _ handler: CoreMidiControlChangeHandler,
        criteria: MidiControllerIdCriteria
    ) {
        let subscriber = ControlChangeHandler(
            criteria: criteria,
            handler: WeakRef(value: handler)
        )
        controlSubscribers.append(subscriber)
    }
    
    func cleanup() {
        controlSubscribers = controlSubscribers.filter {
            $0.handler.value != nil
        }
        noteSubscribers = noteSubscribers.filter {
            $0.handler.value != nil
        }
    }
    
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOn(note) }
            
        case .noteOff(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOff(note) }

        case .controlChange(let controllerId, let value):
            controlChange(controllerId, value)
        }
    }
    
    private func withNoteHandlers(
        on channel: MidiChannel,
        perform action: (CoreMidiNoteHandler) -> Void
    ) {
        noteSubscribers
            .compactMap { data in
                guard let handler = data.handler.value else {
                    return nil
                }
                return data.channel ?? channel == channel ? handler : nil
            }
            .forEach(action)
    }
    
    private func controlChange(_ controllerId: MidiControllerId, _ value: MidiValue) {
        controlSubscribers
            .filter {
                $0.criteria.matches(controllerId)
            }
            .forEach {
                $0.handler.value?.controlChanged(controllerId, value: value)
            }
    }
}
