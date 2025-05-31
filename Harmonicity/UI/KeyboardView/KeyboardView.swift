//
//  KeyboardView.swift
//  Harmonicity
//
//  Created by Sergey on 31.05.2025.
//

import SwiftUI

struct KeyboardView: View {
    let octaves: Range<Int>
    let midiChannel: MidiChannel
    let commandCenter: MidiCommandCenter?
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(octaves, id: \.self) { octave in
                OctaveKeyboardView(octave: octave) { note, isOn in
                    if isOn {
                        commandCenter?.on(note: note.note, velocity: note.velocity, channel: midiChannel)
                    } else {
                        commandCenter?.off(note: note.note, velocity: note.velocity, channel: midiChannel)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    KeyboardView(
        octaves: 3..<6,
        midiChannel: 0,
        commandCenter: nil
    )
}
