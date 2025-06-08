//
//  DelayControlState.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import AVFAudio
import Foundation

final class DelayControlState: MidiControllableState<DelayControlState.State, AVAudioUnitDelay> {
    struct State {
        var delayTime: CoreFloat = 0.15
        var feedback: CoreFloat  = 50
        var lowPassCutoff: CoreFloat = 15000
        var dryWetMix: CoreFloat = 50
    }
    
    let channel: MidiChannel
    let delayCtrl: MidiController
    let feedbackCtrl: MidiController
    let lowPassCutoffCtrl: MidiController
    let dryWetMixCtrl: MidiController
    
    init(
        initial: State,
        channel: MidiChannel,
        delayCtrl: MidiController,
        feedbackCtrl: MidiController,
        lowPassCutoffCtrl: MidiController,
        dryWetMixCtrl: MidiController
    ) {
        self.channel = channel
        self.delayCtrl = delayCtrl
        self.feedbackCtrl = feedbackCtrl
        self.lowPassCutoffCtrl = lowPassCutoffCtrl
        self.dryWetMixCtrl = dryWetMixCtrl
        super.init(initial: initial)
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        guard controllerId.channel == channel else {
            return false
        }
        return controllerId.controller == delayCtrl || controllerId.controller == feedbackCtrl ||
        controllerId.controller == lowPassCutoffCtrl || controllerId.controller == dryWetMixCtrl
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        var next = stored
        switch controllerId.controller {
        case delayCtrl:
            next.delayTime = convertFromMidi(midiValue, toValueFrom: delayRange)
        case feedbackCtrl:
            next.feedback = convertFromMidi(midiValue, toValueFrom: feedbackRange)
        case lowPassCutoffCtrl:
            next.lowPassCutoff = convertFromMidi(midiValue, toValueFrom: lowPassCutoffRange)
        case dryWetMixCtrl:
            next.dryWetMix = convertFromMidi(midiValue, toValueFrom: dryWetRange)
        default:
            return nil
        }
        return next
    }
    
    override func update(_ obj: AVAudioUnitDelay, with value: State) {
        obj.delayTime = value.delayTime
        obj.feedback = Float(value.feedback)
        obj.lowPassCutoff = Float(value.lowPassCutoff)
        obj.wetDryMix = Float(value.dryWetMix)
    }
    
    var delayRange: Range<CoreFloat> {
        0..<2
    }
    
    var feedbackRange: Range<CoreFloat> {
        -100..<100
    }
    
    var lowPassCutoffRange: Range<CoreFloat> {
        // 10 -> (samplerate/2)
        20..<20_000
    }
    
    var dryWetRange: Range<CoreFloat> {
        0..<100
    }
    
}
