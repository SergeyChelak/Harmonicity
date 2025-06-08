//
//  ReverbControlState.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import AVFAudio
import Foundation

final class ReverbControlState: MidiControllableState<ReverbControlState.State, AVAudioUnitReverb> {
    struct State {
        var preset: Int
        var wetDryMix: CoreFloat
    }
 
    let presets: [AVAudioUnitReverbPreset]
    let channel: MidiChannel
    let presetCtrl: MidiController
    let dryWetMixCtrl: MidiController
    
    init(
        initial: State,
        presets: [AVAudioUnitReverbPreset],
        channel: MidiChannel,
        presetCtrl: MidiController,
        dryWetMixCtrl: MidiController
    ) {
        self.presets = presets
        self.channel = channel
        self.presetCtrl = presetCtrl
        self.dryWetMixCtrl = dryWetMixCtrl
        super.init(initial: initial)
    }
    
    var dryWetRange: Range<CoreFloat> {
        0..<100
    }
    
    override func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        guard controllerId.channel == channel else {
            return false
        }
        return controllerId.controller == presetCtrl || controllerId.controller == dryWetMixCtrl
    }
    
    override func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: State) -> State? {
        var next = stored
        if controllerId.controller == presetCtrl {
            next.preset = Int(midiValue) % presets.count
            return next
        }
        
        if controllerId.controller == dryWetMixCtrl {
            next.wetDryMix = convertFromMidi(midiValue, toValueFrom: dryWetRange)
            return next
        }
        
        return nil
    }
    
    override func update(_ obj: AVAudioUnitReverb, with value: State) {
        print(value)
        obj.wetDryMix = Float(value.wetDryMix)
        obj.loadFactoryPreset(presets[value.preset])
    }
}
