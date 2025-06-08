//
//  OscillatorSelectorGroupView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

struct OscillatorSelectorGroupView: View {
    private let states: [SelectableOscillatorState]
    
    init(states: [SelectableOscillatorState]) {
        self.states = states
    }
    
    var body: some View {
        VStack {
            Text("Voice")
                .font(.title)
                .padding(.bottom, 10)
            ForEach(states.indices, id: \.self) { index in
                OscillatorSelectorView(
                    state: states[index]
                )
                if index < states.count - 1 {
                    Divider()
                }
            }
        }
        .groupStyle()
    }
}

#Preview {
    let controllerId = MidiControllerId(channel: 0, controller: 0)
    let state = SelectableOscillatorState(
        initial: 0,
        waveForms: [.sine, .triangle, .sawtooth, .square],
        controllerId: controllerId
    )
    
    OscillatorSelectorGroupView(
        states: [state, state, state]
    )
}
