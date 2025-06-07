//
//  DetuneControlGroupView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

struct DetuneControlGroupView: View {
    private let states: [DetunedOscillatorState]
    
    init(states: [DetunedOscillatorState]) {
        self.states = states
    }
    
    var body: some View {
        VStack {
            Text("Detune")
                .font(.title)
                .padding(.bottom, 10)
            ForEach(states.indices, id: \.self) { index in
                DetuneControlView()
                if index < states.count - 1 {
                    Divider()
                }
            }
        }
        .frame(width: 250)
        .groupStyle()
        
    }
}

#Preview {
    let controlId = MidiControllerId(channel: 0, controller: 0)
    let state = DetunedOscillatorState(initial: 0, controllerId: controlId)
    DetuneControlGroupView(
        states: [state, state, state]
    )
}
