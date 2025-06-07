//
//  Context.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class Context {
    private let midiInput: MidiInputService
    let commandCenter: MidiCommandCenter
    private let synthesizer: Synthesizer
    let midiStates: MidiControllerStates
    
    init(
        midiInput: MidiInputService,
        commandCenter: MidiCommandCenter,
        synthesizer: Synthesizer,
        midiStates: MidiControllerStates
    ) {
        self.midiInput = midiInput
        self.commandCenter = commandCenter
        self.synthesizer = synthesizer
        self.midiStates = midiStates
    }
}

func composeContext() throws -> Context {
    let engine = AudioEngine()
    
    let commandCenter = MidiCommandCenter()
    let midiInput = MidiInputService(commandCenter)
    try midiInput.setup()
    
    let factory = WaveOscillatorFactory(
        sampleRate: engine.sampleRate
    )
    
    let config = Configuration(channel: virtualMidiChannel)
    let midiStates = MidiControllerStates(config: config)
    
    let composer = VoiceComposer(
        sampleRate: engine.sampleRate,
        oscillatorFactory: factory,
        midiStates: midiStates,
        config: config
    )
    
    let synthesizer = Synthesizer(
        voice: composer.voice(),
        engine: engine,
        controlHandler: midiStates,
        commandPublisher: commandCenter.publisher
    )
    try synthesizer.start()
    
    let context = Context(
        midiInput: midiInput,
        commandCenter: commandCenter,
        synthesizer: synthesizer,
        midiStates: midiStates
    )
    
    return context
}
