//
//  MixerControlView.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import Combine
import SwiftUI

struct MixerControlView: View {
    @ObservedObject private var viewModel: MixerControlViewModel
    
    init(state: MixerOscillatorState) {
        self.viewModel = MixerControlViewModel(state: state)
    }
    
    var body: some View {
        VStack {
            Text("Volume")
                .font(.title)
                .padding(.bottom, 10)
            ForEach(viewModel.levels.indices, id: \.self) { index in
                HStack {
                    Button {
                        viewModel.valueChanged(index: index, value: 0)
                    } label: {
                        Text("Off")
                    }
                    Spacer()
                    Button {
                        viewModel.valueChanged(index: index, value: maxMidiValue)
                    } label: {
                        Text("Max")
                    }
                }
                SliderView(
                    viewModel.levels[index],
                    formatter: viewModel.formattedValue
                ) {
                    viewModel.valueChanged(index: index, value: $0)
                }
                if index < viewModel.levels.count - 1 {
                    Divider()
                }
            }
        }
        .frame(width: 250)
        .groupStyle()
    }
}

final class MixerControlViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private let state: MixerOscillatorState
    @Published private(set) var levels: [CoreFloat] = []
    
    init(state: MixerOscillatorState) {
        self.state = state
        self.cancellable = state.publisher
            .sink { [weak self] value in
                self?.levels = value
                    .map { convertToMidi($0, from: state.volumeRange) }
                    .map { CoreFloat($0) }
            }
    }

    func formattedValue(_ midiValue: MidiValue) -> String {
        let value = CoreFloat(midiValue) / CoreFloat(maxMidiValue) * 100
        return "\(Int(value)) %"
    }
    
    func valueChanged(index: Int, value: MidiValue) {
        let controllerId = MidiControllerId(
            channel: state.channel,
            controller: state.controllers[index]
        )
        state.controlChanged(controllerId, value: value)
    }
}

#Preview {
    let state = MixerOscillatorState(
        initial: [1, 1, 1],
        channel: virtualMidiChannel,
        controllers: [1, 2, 3]
    )
    MixerControlView(state: state)
}
