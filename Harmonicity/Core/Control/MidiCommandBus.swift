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
        let channel: MidiChannel?
        let controller: MidiController
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
    
    func add(_ handler: CoreMidiNoteHandler, on channel: MidiChannel?) {
        let subscriber = NoteHandler(
            channel: channel,
            handler: WeakRef(value: handler)
        )
        noteSubscribers = noteSubscribers.filter { $0.handler.value != nil }
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
            handler: WeakRef(value: handler)
        )
        controlSubscribers = controlSubscribers.filter { $0.handler.value != nil }
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
                .filter {
                    ($0.channel ?? channel) == channel && $0.controller == data.controller
                }
                .forEach {
                    $0.handler.value?.controlChanged(data.controller, value: data.value)
                }
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
}
