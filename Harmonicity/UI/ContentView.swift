//
//  ContentView.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

struct ContentView: View {
    let synth: Synthesizer
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(3...5, id: \.self) { octave in
                KeyboardView(octave: octave) {
                    synth.play($0)
                }
            }
        }
        .padding()
    }
}
