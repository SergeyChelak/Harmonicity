//
//  EnvelopControlView.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import Combine
import SwiftUI

struct EnvelopControlView: View {
    @ObservedObject private var viewModel: EnvelopControlViewModel
    
    init(state: EnvelopeFilterState) {
        self.viewModel = EnvelopControlViewModel(state: state)
    }
    
    var body: some View {
        VStack {
            Text("Attack")
            SliderView(
                viewModel.attack,
                formatter: { viewModel.format(.attack, $0) }
            ) { viewModel.valueChanged(.attack, $0) }
            Divider()
            
            Text("Decay")
            SliderView(
                viewModel.decay,
                formatter: { viewModel.format(.decay, $0) }
            ) { viewModel.valueChanged(.decay, $0) }
            Divider()
            
            Text("Sustain")
            SliderView(
                viewModel.sustain,
                formatter: { viewModel.format(.sustain, $0) }
            ) { viewModel.valueChanged(.sustain, $0) }
            Divider()
            
            Text("Release")
            SliderView(
                viewModel.release,
                formatter: { viewModel.format(.release, $0) }
            ) { viewModel.valueChanged(.release, $0) }
            
        }
    }
}

final class EnvelopControlViewModel: ObservableObject {
    enum Parameter {
        case attack, decay, sustain, release
    }
    
    private var cancellable: AnyCancellable?
    private let state: EnvelopeFilterState
    @Published private(set) var attack: CoreFloat = 0
    @Published private(set) var decay: CoreFloat = 0
    @Published private(set) var sustain: CoreFloat = 0
    @Published private(set) var release: CoreFloat = 0
    
    init(state: EnvelopeFilterState) {
        self.state = state
        self.cancellable = state.publisher.sink { [weak self] in
            self?.attack = CoreFloat(convertToMidi($0.attackTime, from: state.attackTimeRange))
            self?.decay = CoreFloat(convertToMidi($0.decayTime, from: state.decayTimeRange))
            self?.sustain = CoreFloat(convertToMidi($0.sustainLevel, from: state.sustainLevelRange))
            self?.release = CoreFloat(convertToMidi($0.releaseTime, from: state.releaseTimeRange))
        }
    }
    
    func valueChanged(_ parameter: Parameter, _ value: MidiValue) {
        let control = switch parameter {
        case .attack:
            state.attackCtrl
        case .decay:
            state.decayCtrl
        case .sustain:
            state.sustainCtrl
        case .release:
            state.releaseCtrl
        }
        let controllerId = MidiControllerId(
            channel: state.channel,
            controller: control
        )
        state.controlChanged(controllerId, value: value)
    }
        
    func format(_ parameter: Parameter, _ value: MidiValue) -> String {
        let range = switch parameter {
        case .attack:
            state.attackTimeRange
        case .decay:
            state.decayTimeRange
        case .sustain:
            state.sustainLevelRange
        case .release:
            state.releaseTimeRange
        }
        let value = convertFromMidi(value, toValueFrom: range)
        
        return switch parameter {
        case .attack, .decay, .release:
            "\(Int(value * 1000)) ms"
        case .sustain:
            "\(Int(value * 100)) %"
        }
    }
}

#Preview {
    let state = EnvelopeFilterState(
        initial: .init(),
        channel: 0,
        attackCtrl: 1,
        decayCtrl: 2,
        sustainCtrl: 3,
        releaseCtrl: 4
    )
    EnvelopControlView(state: state)
}
