//
//  EnvelopeFilterState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Foundation

class EnvelopeFilterState: MidiControllableState<EnvelopeFilterState.State, ADSRFilter> {
    typealias State = ADSRFilter.EnvelopeData
    
    let channel: MidiChannel
    let attackCtrl: MidiController
    let decayCtrl: MidiController
    let sustainCtrl: MidiController
    let releaseCtrl: MidiController
    
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
        return controllerId.controller == attackCtrl ||
        controllerId.controller == decayCtrl ||
        controllerId.controller == sustainCtrl ||
        controllerId.controller == releaseCtrl
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        var next = stored
        if controllerId.controller == attackCtrl {
            next.attackTime = convertFromMidi(midiValue, toValueFrom: attackTimeRange)
            return next
        }
        if controllerId.controller == decayCtrl {
            next.decayTime = convertFromMidi(midiValue, toValueFrom: decayTimeRange)
            return next
        }
        if controllerId.controller == sustainCtrl {
            next.sustainLevel = convertFromMidi(midiValue, toValueFrom: sustainLevelRange)
            return next
        }
        if controllerId.controller == releaseCtrl {
            next.releaseTime = convertFromMidi(midiValue, toValueFrom: releaseTimeRange)
            return next
        }
        return nil
    }
    
    override func update(_ obj: ADSRFilter, with value: State) {
        obj.setEnvelope(value)
    }
    
    var attackTimeRange: Range<CoreFloat> {
        0..<0.2
    }
    
    var decayTimeRange: Range<CoreFloat> {
        0..<0.2
    }
    
    var sustainLevelRange: Range<CoreFloat> {
        0..<1
    }
    
    var releaseTimeRange: Range<CoreFloat> {
        0..<0.2
    }
}
