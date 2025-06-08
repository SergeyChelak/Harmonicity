//
//  SynthesizerView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct SynthesizerView: View {
    private let controlHeight: CGFloat = 350
    let context: Context
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack(spacing: 16) {
                OscillatorSelectorGroupView(
                    states: context.midiStates.selectableOscillatorStates
                )
                .groupStyle(title: "Voice", height: controlHeight)
                
                DetuneControlGroupView(
                    states: context.midiStates.detunedOscillatorStates
                )
                .frame(height: 350)
                .groupStyle(title: "Detune", height: controlHeight)
                
                MixerControlView(
                    state: context.midiStates.mixerOscillatorState
                )
                .frame(height: 350)
                .groupStyle(title: "Mixing", height: controlHeight)
                
                EnvelopControlView(
                    state: context.midiStates.envelopeFilterState
                )
                .frame(height: 350)
                .groupStyle(title: "Envelope", height: controlHeight)
            }
            
            KeyboardView(
                octaves: 3..<6,
                midiChannel: virtualMidiChannel,
                commandCenter: context.commandCenter
            )
        }
        .padding()        
    }
}
