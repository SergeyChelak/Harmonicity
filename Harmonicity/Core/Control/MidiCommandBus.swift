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
        let handler: CoreMidiNoteHandler
    }
    
    private struct ControlChangeHandler {
        let channel: MidiChannel?
        let controller: MidiController
        let handler: CoreMidiControlChangeHandler
    }

    // TODO: memory leak source
    private var noteSubscribers: [NoteHandler] = []
    
    private var controlSubscribers: [ControlChangeHandler] = []
    
    init(publisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = publisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
    
    func add(_ handler: CoreMidiNoteHandler, on channel: MidiChannel?) {
        let subscriber = NoteHandler(
            channel: channel,
            handler: handler
        )
        noteSubscribers.append(subscriber)
    }
    
    func add(
        _ handler: CoreMidiControlChangeHandler,
        controller: MidiController,
        on channel: MidiChannel?
    ) {
        let subscriber = ControlChangeHandler(
            channel: channel,
            controller: controller,
            handler: handler
        )
        controlSubscribers.append(subscriber)
    }
    
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOn(note) }
            
        case .noteOff(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOff(note) }

        case .controlChange(let channel, let data):
            controlSubscribers
                .compactMap { data in
                    data.channel ?? channel == channel ? data.handler : nil
                }
                .forEach {
                    $0.controlChanged(data.controller, value: data.value)
                }
        }
    }
    
    private func withNoteHandlers(
        on channel: MidiChannel,
        perform action: (CoreMidiNoteHandler) -> Void
    ) {
        noteSubscribers
            .compactMap { data in
                data.channel ?? channel == channel ? data.handler : nil
            }
            .forEach(action)
    }
}
