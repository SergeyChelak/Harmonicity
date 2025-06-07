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
        state: SelectableOscillatorState,
        controllerId: MidiControllerId
    ) {
        viewModel = OscillatorSelectorViewModel(
            state: state,
            controllerId: controllerId
        )
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
    private let controllerId: MidiControllerId
    
    @Published private(set) var selected: Int
    
    init(
        state: SelectableOscillatorState,
        controllerId: MidiControllerId
    ) {
        self.state = state
        self.selected = state.storedValue
        self.controllerId = controllerId
        self.cancellable = state.publisher.sink { [weak self] in
            self?.selected = $0
        }
    }
    
    var title: String {
        let waveForm = state.waveForms[selected]
        let waveName = switch waveForm {
        case .sine:
            "Sine"
        case .square:
            "Square"
        case .triangle:
            "Triangle"
        case .sawtooth:
            "Sawtooth"
        }
        return "\(waveName) Oscillator"
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
        state.controlChanged(controllerId, value: value)
    }
}

//#Preview {
//    OscillatorSelectorView(states: [])
//}
