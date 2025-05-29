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
        HStack(spacing: 4) {
            ForEach(3...5, id: \.self) { octave in
                KeyboardView(octave: octave) { note, isOn in
                    if isOn {
                        context.commandCenter.on(note: note.note, velocity: note.velocity, channel: 0)
                    } else {
                        context.commandCenter.off(note: note.note, velocity: note.velocity, channel: 0)
                    }
                }
            }
        }
        .padding()
    }
}
