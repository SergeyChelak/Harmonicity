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
    let midiStates: MidiControllerStates
    private let voice: CoreVoice
        
    init(
        voice: CoreVoice,
        engine: AudioEngine,
        midiStates: MidiControllerStates,
        commandPublisher: AnyPublisher<MidiCommand, Never>
    ) {
        self.voice = voice
        self.engine = engine
        self.midiStates = midiStates
        setupObservables(commandPublisher: commandPublisher)
    }
        
    func start() throws {
        engine.stop()
        engine.sampleSource = voice
        try engine.setup()
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
            midiStates.controlChanged(controllerId, value: value)
        }
    }
}
