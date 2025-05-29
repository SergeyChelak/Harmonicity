//
//  Context.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class Context {
    let engine: AudioEngine
    let midiInput: MidiInputService
    let commandCenter: MidiCommandCenter
    let synthesizer: Synthesizer
    
    init(
        engine: AudioEngine,
        midiInput: MidiInputService,
        commandCenter: MidiCommandCenter,
        synthesizer: Synthesizer
    ) {
        self.engine = engine
        self.midiInput = midiInput
        self.commandCenter = commandCenter
        self.synthesizer = synthesizer
    }
}

func composeContext() throws -> Context {
    let engine = AudioEngine()
    try engine.setup()
    
    let commandCenter = MidiCommandCenter()
    let midiInput = MidiInputService(commandCenter)
    
    let factory = WaveOscillatorFactory(
        sampleRate: engine.sampleRate
    )
    
    let synthesizer = composeSynthesizer(
        midiCommandCenter: commandCenter,
        oscillatorFactory: factory,
        engine: engine
    )

    let context = Context(
        engine: engine,
        midiInput: midiInput,
        commandCenter: commandCenter,
        synthesizer: synthesizer
    )
    
    return context
}
