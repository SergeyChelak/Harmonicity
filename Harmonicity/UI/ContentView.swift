//
//  ContentView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct ContentView: View {
    let context: Context
    
    var body: some View {
        VStack(spacing: 4) {
            
            VStack {
                switcher()
                Divider()
                switcher()
                Divider()
                switcher()
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(lineWidth: 4)
                    .foregroundStyle(.yellow)
            }
            .frame(width: 150)
            
            
            KeyboardView(
                octaves: 3..<6,
                midiChannel: virtualMidiChannel,
                commandCenter: context.commandCenter
            )
        }
        .padding()        
    }
}

func switcher() -> Switcher {
    let viewModel = SwitcherViewModel(items: [
        .image("sawtooth-wave"),
        .image("sine-wave"),
        .image("square-wave"),
        .image("triangle-wave")
    ])
    return Switcher(viewModel: viewModel)
}
