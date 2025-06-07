//
//  OscillatorSelectorGroupView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

struct OscillatorSelectorGroupView: View {
    private let states: [SelectableOscillatorState]
    private let controllerIds: [MidiControllerId]
    
    init(
        states: [SelectableOscillatorState],
        controllerIds: [MidiControllerId]
    ) {
        assert(states.count == controllerIds.count)
        self.states = states
        self.controllerIds = controllerIds
    }
    
    var body: some View {
        VStack {
            ForEach(states.indices, id: \.self) { index in
                OscillatorSelectorView(
                    state: states[index],
                    controllerId: controllerIds[index]
                )
                if index < states.count - 1 {
                    Divider()
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 4)
                .foregroundStyle(.yellow)
        }
        .frame(width: 150)

    }
}

#Preview {
    OscillatorSelectorGroupView(
        states: [],
        controllerIds: []
    )
}
