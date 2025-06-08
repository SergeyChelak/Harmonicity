//
//  SynthesizerView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct SynthesizerView: View {
    private let voiceControlHeight: CGFloat = 350
    private let postProcessControlHeight: CGFloat = 100
    let context: Context
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 16) {
                OscillatorSelectorGroupView(
                    states: context.midiStates.selectableOscillatorStates
                )
                .groupStyle(title: "Voice", height: voiceControlHeight)
                
                DetuneControlGroupView(
                    states: context.midiStates.detunedOscillatorStates
                )
                .groupStyle(title: "Detune", height: voiceControlHeight)
                
                MixerControlView(
                    state: context.midiStates.mixerOscillatorState
                )
                .groupStyle(title: "Mixing", height: voiceControlHeight)
                
                EnvelopControlView(
                    state: context.midiStates.envelopeFilterState
                )
                .groupStyle(title: "Envelope", height: voiceControlHeight)
            }
            
            HStack(spacing: 16) {
                DelayControlView()
                    .groupStyle(title: "Delay", height: postProcessControlHeight)
                
                ReverbControlView(
                    state: context.midiStates.reverbControlState
                )
                .groupStyle(title: "Reverb", height: postProcessControlHeight)
            }
            
            KeyboardView(
                octaves: 3..<6,
                midiChannel: virtualMidiChannel,
                commandCenter: context.commandCenter
            )
//            .groupStyle(title: "", height: 150)
        }
        .padding()        
    }
}
