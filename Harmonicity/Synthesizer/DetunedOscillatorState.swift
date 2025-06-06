//
//  DetunedOscillatorState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class DetunedOscillatorState: MidiControllableState<DetunedOscillatorState.State, DetunedOscillator> {
    typealias State = CoreFloat
    private let controllerId: MidiControllerId
    
    init(
        initial: State,
        channel: MidiChannel,
        controller: MidiController
    ) {
        self.controllerId = MidiControllerId(
            channel: channel,
            controller: controller
        )
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        self.controllerId == controllerId
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        // TODO: this is a bullshit
        CoreFloat(midiValue) - CoreFloat(MidiValue.max / 2)
    }
    
    override func update(_ obj: DetunedOscillator, with value: State) {
        obj.setDetune(value)
    }
}
