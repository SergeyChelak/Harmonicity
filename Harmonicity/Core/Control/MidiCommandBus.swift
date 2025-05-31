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
    private var noteSubscribers: [CoreMIDINoteHandler] = []
    
    init(publisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = publisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
    
    func add(_ noteSubscriber: CoreMIDINoteHandler) {
        noteSubscribers.append(noteSubscriber)
    }
    
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(let channel, let note):
            guard channel == 0 else { break }
            noteSubscribers.forEach { $0.noteOn(note) }
            
        case .noteOff(let channel, let note):
            guard channel == 0 else { break }
            noteSubscribers.forEach { $0.noteOff(note) }

        default: break
//        case .controlChange(let channel, let data):
//            break
        }
    }
}
