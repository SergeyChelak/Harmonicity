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
            ForEach(states.indices, id: \.self) { index in
                DetuneControlView(state: states[index])
                if index < states.count - 1 {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    let controlId = MidiControllerId(channel: 0, controller: 0)
    let state = DetunedOscillatorState(initial: 0, controllerId: controlId)
    DetuneControlGroupView(
        states: [state, state, state]
    )
}
