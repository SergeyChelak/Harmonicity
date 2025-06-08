//
//  DetuneControlView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Combine
import SwiftUI

struct DetuneControlView: View {
    @ObservedObject private var viewModel: DetuneControlViewModel
    
    init(state: DetunedOscillatorState) {
        self.viewModel = DetuneControlViewModel(state: state)
    }
    
    var body: some View {
        VStack {
            Button(action: viewModel.reset) {
                Text("Reset")
            }
            SliderView(
                viewModel.midiFloatValue,
                formatter: viewModel.formattedValue,
                handler: viewModel.valueChanged
            )
        }
    }
}

final class DetuneControlViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private let state: DetunedOscillatorState
    @Published private(set) var midiFloatValue: CoreFloat = 0
    
    init(state: DetunedOscillatorState) {
        self.state = state
        self.cancellable = state.publisher
            .sink { [weak self] in
                let midi = convertToMidi($0, from: state.detuneRange)
                self?.midiFloatValue = CoreFloat(midi)
            }
    }
    
    func valueChanged(_ value: MidiValue) {
        state.controlChanged(state.controllerId, value: value)
    }
    
    func reset() {
        let zero = convertToMidi(0, from: state.detuneRange)
        valueChanged(zero)
    }
    
    func formattedValue(_ midiValue: MidiValue) -> String {
        let value = convertFromMidi(midiValue, toValueFrom: state.detuneRange)
        return "\(Int(value)) cents"
    }
}

#Preview {
    let controlId = MidiControllerId(channel: 0, controller: 0)
    let state = DetunedOscillatorState(initial: 0, controllerId: controlId)
    DetuneControlView(state: state)
}
