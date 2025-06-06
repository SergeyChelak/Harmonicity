//
//  EnvelopeFilterState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class EnvelopeFilterState: MidiControllableState<EnvelopeFilterState.State, ADSRFilter> {
    typealias State = ADSRFilter.EnvelopeData
    
    private let channel: MidiChannel
    private let attackCtrl: MidiController
    private let decayCtrl: MidiController
    private let sustainCtrl: MidiController
    private let releaseCtrl: MidiController
    
    init(
        initial: State,
        channel: MidiChannel,
        attackCtrl: MidiController,
        decayCtrl: MidiController,
        sustainCtrl: MidiController,
        releaseCtrl: MidiController
    ) {
        self.channel = channel
        self.attackCtrl = attackCtrl
        self.decayCtrl = decayCtrl
        self.sustainCtrl = sustainCtrl
        self.releaseCtrl = releaseCtrl
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        guard self.channel == controllerId.channel else {
            return false
        }
        return controllerId.channel == attackCtrl ||
            controllerId.channel == decayCtrl ||
            controllerId.channel == sustainCtrl ||
            controllerId.channel == releaseCtrl
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        let ratio = CoreFloat(midiValue) / CoreFloat(maxMidiValue)
        var next = stored
        if controllerId.channel == attackCtrl {
            // 0 - 0.2
            next.attackTime = 0.2 * ratio
            return next
        }
        if controllerId.channel == decayCtrl {
            // 0 - 0.1
            next.decayTime = 0.1 * ratio
            return next
        }
        if controllerId.channel == sustainCtrl {
            // 0 - 1
            next.sustainLevel = ratio
            return next
        }
        if controllerId.channel == releaseCtrl {
            // 0 - 0.1
            next.releaseTime = 0.1 * ratio
            return next
        }
        return nil
    }
    
    override func update(_ obj: ADSRFilter, with value: State) {
        obj.setEnvelope(value)
    }
}
