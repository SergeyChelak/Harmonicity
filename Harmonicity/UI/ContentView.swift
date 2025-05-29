//
//  ContentView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct ContentView: View {
    let context: HarmonicityAppContext
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(3...5, id: \.self) { octave in
                KeyboardView(octave: octave) { note, isOn in
                    if isOn {
                        context.synth.noteOn(note)
                    } else {
                        context.synth.noteOff(note)
                    }
                }
            }
        }
        .padding()
    }
}
