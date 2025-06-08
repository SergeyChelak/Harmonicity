//
//  MixerOscillatorState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class MixerOscillatorState: MidiControllableState<MixerOscillatorState.State, MixedOscillator> {
    typealias State = [CoreFloat]
    let channel: MidiChannel
    let controllers: [MidiController]
    
    init(
        initial: State,
        channel: MidiChannel,
        controllers: [MidiController]
    ) {
        assert(initial.count == controllers.count)
        self.channel = channel
        self.controllers = controllers
        super.init(initial: initial)
    }
        
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        guard self.channel == controllerId.channel else {
            return false
        }
        return controllers.contains(controllerId.controller)
    }
    
    override func map(
        _ controllerId: MidiControllerId,
        midiValue: MidiValue,
        stored: State
    ) -> State? {
        guard let index = controllers.firstIndex(of: controllerId.controller),
              index < stored.count else {
            return nil
        }
        var next = stored
        next[index] = convertFromMidi(midiValue, toValueFrom: volumeRange)
        return next
    }
    
    override func update(_ obj: MixedOscillator, with value: State) {
        obj.setWeights(value)
    }
    
    var volumeRange: Range<CoreFloat> {
        0..<1
    }
}
