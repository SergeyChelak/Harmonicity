//
//  SynthesizerView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct SynthesizerView: View {
    let context: Context
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack(spacing: 16) {
                OscillatorSelectorGroupView(
                    states: context.midiStates.selectableOscillatorStates
                )
                
                DetuneControlGroupView(
                    states: context.midiStates.detunedOscillatorStates
                )
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
