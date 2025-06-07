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
            OscillatorSelectorGroupView(
                states: context.midiStates.selectableOscillatorStates,
                controllerIds: context.config.selectableOscillatorControl
            )
            
            KeyboardView(
                octaves: 3..<6,
                midiChannel: virtualMidiChannel,
                commandCenter: context.commandCenter
            )
        }
        .padding()        
    }
}
