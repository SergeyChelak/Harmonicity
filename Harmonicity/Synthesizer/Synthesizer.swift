//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import Combine
import Foundation

final class Synthesizer {
    private var cancellable: AnyCancellable?
    
    private let engine: AudioEngine
    private let states: MidiControllerStates
    private let voice: CoreVoice
        
    init(
        voice: CoreVoice,
        engine: AudioEngine,
        states: MidiControllerStates,
        commandPublisher: AnyPublisher<MidiCommand, Never>
    ) {
        self.voice = voice
        self.engine = engine
        self.states = states
        setupObservables(commandPublisher: commandPublisher)
    }
        
    func start() throws {
        engine.stop()
        try engine.setup(voice, states)
        try engine.start()
    }
            
    // MARK: -- handle midi events
    private func setupObservables(commandPublisher: AnyPublisher<MidiCommand, Never>) {
        cancellable = commandPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
    }
        
    private func handleEvent(_ event: MidiCommand) {
        switch event {
        case .noteOn(_, let note):
            voice.noteOn(note)
            
        case .noteOff(_, let note):
            voice.noteOff(note)

        case .controlChange(let controllerId, let value):
            states.controlChanged(controllerId, value: value)
        }
    }
}
