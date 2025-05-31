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
            KeyboardView(
                octaves: 3..<6,
                midiChannel: 0,
                commandCenter: context.commandCenter
            )
        }
        .padding()
    }
}
