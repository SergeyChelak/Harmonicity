//
//  SelectableOscillatorState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class SelectableOscillatorState: MidiControllableState<SelectableOscillatorState.State, SelectableOscillator> {
    typealias State = Int
    let waveForms: [Configuration.WaveForm]
    let controllerId: MidiControllerId
    
    init(
        initial: State,
        waveForms: [Configuration.WaveForm],
        controllerId: MidiControllerId
    ) {
        self.waveForms = waveForms
        self.controllerId = controllerId
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        self.controllerId == controllerId
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        State(midiValue) % waveForms.count
    }
    
    override func update(_ obj: SelectableOscillator, with value: State) {
        obj.setCurrent(value)
    }
}
