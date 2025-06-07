//
//  DetunedOscillatorState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class DetunedOscillatorState: MidiControllableState<DetunedOscillatorState.State, DetunedOscillator> {
    typealias State = CoreFloat
    let controllerId: MidiControllerId
    
    init(
        initial: State,
        controllerId: MidiControllerId
    ) {
        self.controllerId = controllerId
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        self.controllerId == controllerId
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        convertFromMidi(midiValue, toValueFrom: detuneRange)
    }
    
    override func update(_ obj: DetunedOscillator, with value: State) {
        obj.setDetune(value)
    }
    
    var detuneRange: Range<CoreFloat> {
        -24.0..<24.0
    }
}
