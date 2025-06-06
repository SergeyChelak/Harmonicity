//
//  Context.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class Context {
    let midiInput: MidiInputService
    let commandCenter: MidiCommandCenter
    let synthesizer: Synthesizer
    
    init(
        midiInput: MidiInputService,
        commandCenter: MidiCommandCenter,
        synthesizer: Synthesizer
    ) {
        self.midiInput = midiInput
        self.commandCenter = commandCenter
        self.synthesizer = synthesizer
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
    
    let config = SynthesizerConfiguration()
    
    let synthesizer = Synthesizer(
        configuration: config,
        engine: engine,
        commandPublisher: commandCenter.publisher,
        oscillatorFactory: factory
    )
    try synthesizer.reconfigure()
    
    let context = Context(
        midiInput: midiInput,
        commandCenter: commandCenter,
        synthesizer: synthesizer
    )
    
    return context
}
