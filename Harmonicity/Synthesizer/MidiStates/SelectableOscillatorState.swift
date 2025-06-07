//
//  SelectableOscillatorState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class SelectableOscillatorState: MidiControllableState<SelectableOscillatorState.State, SelectableOscillator> {
    typealias State = Int
    private let maxValue: State
    private let controllerId: MidiControllerId
    
    init(
        initial: State,
        maxValue: State,
        controllerId: MidiControllerId
    ) {
        self.maxValue = maxValue
        self.controllerId = controllerId
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        self.controllerId == controllerId
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        State(midiValue) % maxValue
    }
    
    override func update(_ obj: SelectableOscillator, with value: State) {
        obj.setCurrent(value)
    }
}
