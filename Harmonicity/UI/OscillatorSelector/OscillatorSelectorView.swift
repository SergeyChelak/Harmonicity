//
//  OscillatorSelectorView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI
import Combine

struct OscillatorSelectorView: View {
    @ObservedObject private var viewModel: OscillatorSelectorViewModel
    
    init(
        state: SelectableOscillatorState
    ) {
        viewModel = OscillatorSelectorViewModel(state: state)
    }
    
    var body: some View {
        VStack {
            Text(viewModel.title)
            SwitcherView(
                items: viewModel.items,
                selected: viewModel.selected,
                handler: viewModel.changeSelection(_:)
            )
        }
    }
}

class OscillatorSelectorViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private let state: SelectableOscillatorState
    @Published private(set) var selected: Int = 0
    
    init(
        state: SelectableOscillatorState
    ) {
        self.state = state
        self.cancellable = state.publisher.sink { [weak self] in
            self?.selected = $0
        }
    }
    
    var title: String {
        let waveForm = state.waveForms[selected]
        return switch waveForm {
        case .sine:
            "Sine"
        case .square:
            "Square"
        case .triangle:
            "Triangle"
        case .sawtooth:
            "Sawtooth"
        }
    }
    
    var items: [SwitcherContent] {
        state.waveForms.map { waveForm -> (SwitcherContent) in
            switch waveForm {
            case .sine:
                    .image("sine-wave")
            case .sawtooth:
                    .image("sawtooth-wave")
            case .square:
                    .image("square-wave")
            case .triangle:
                    .image("triangle-wave")
                
            }
        }
    }
    
    func changeSelection(_ newValue: Int) {
        let value = MidiValue(newValue)
        state.controlChanged(state.controllerId, value: value)
    }
}

#Preview {
    let controllerId = MidiControllerId(channel: 0, controller: 0)
    let state = SelectableOscillatorState(
        initial: 0,
        waveForms: [.sine, .triangle, .sawtooth, .square],
        controllerId: controllerId
    )
    return OscillatorSelectorView(state: state)
}
