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

    // TODO: memory leak source
    private var noteSubscribers: [(CoreMIDINoteHandler, MidiChannel?)] = []
    
    init(publisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = publisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
    
    func add(_ noteSubscriber: CoreMIDINoteHandler, on channel: MidiChannel?) {
        noteSubscribers.append((noteSubscriber, channel))
    }
    
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOn(note) }
            
        case .noteOff(let channel, let note):
            withNoteHandlers(on: channel) { $0.noteOff(note) }

        default: break
//        case .controlChange(let channel, let data):
//            break
        }
    }
    
    private func withNoteHandlers(
        on channel: MidiChannel,
        perform action: (CoreMIDINoteHandler) -> Void
    ) {
        noteSubscribers
            .compactMap { (receiver, reqChannel) in
                reqChannel ?? channel == channel ? receiver : nil
            }
            .forEach(action)
    }
}
