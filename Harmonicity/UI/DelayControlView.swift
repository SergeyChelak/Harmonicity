//
//  DelayControlView.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import Combine
import SwiftUI

struct DelayControlView: View {
    @ObservedObject private var viewModel: DelayControlViewModel
    
    init(state: DelayControlState) {
        self.viewModel = DelayControlViewModel(state: state)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Delay Time")
                SliderView(
                    viewModel.delayTime,
                    formatter: viewModel.delayFormat(_:)
                ) { viewModel.valueChanged(.delay, $0) }
                Divider()
                Text("Feedback")
                SliderView(
                    viewModel.feedback,
                    formatter: viewModel.feedbackFormat(_:)
                ) { viewModel.valueChanged(.feedback, $0) }
            }
            VStack {
                Text("Low Pass Cutoff")
                SliderView(
                    viewModel.lowPassCutoff,
                    formatter: viewModel.lowPassCutoffFormat(_:)
                ) { viewModel.valueChanged(.lowPassCutoff, $0) }
                Divider()
                Text("Dry/Wet Mix")
                SliderView(
                    viewModel.dryWetMix,
                    formatter: viewModel.dryWetMixFormat(_:)
                ) { viewModel.valueChanged(.dryWetMix, $0) }
            }
        }
    }
}

final class DelayControlViewModel: ObservableObject {
    enum Parameter {
        case delay, feedback, lowPassCutoff, dryWetMix
    }
    
    private var cancellable: AnyCancellable?
    private let state: DelayControlState
    
    @Published private(set) var delayTime: CoreFloat = 0
    @Published private(set) var feedback: CoreFloat = 0
    @Published private(set) var lowPassCutoff: CoreFloat = 0
    @Published private(set) var dryWetMix: CoreFloat = 0
    
    init(state: DelayControlState) {
        self.state = state
        self.cancellable = state.publisher.sink { [weak self] in
            self?.delayTime = CoreFloat(convertToMidi($0.delayTime, from: state.delayRange))
            self?.feedback = CoreFloat(convertToMidi($0.feedback, from: state.feedbackRange))
            self?.lowPassCutoff = CoreFloat(convertToMidi($0.lowPassCutoff, from: state.lowPassCutoffRange))
            self?.dryWetMix = CoreFloat(convertToMidi($0.dryWetMix, from: state.dryWetRange))
        }
    }
    
    func delayFormat(_ value: MidiValue) -> String {
        let value = 1000 * convertFromMidi(value, toValueFrom: state.delayRange)
        return "\(Int(value)) ms"
    }
    
    func feedbackFormat(_ value: MidiValue) -> String {
        let value = convertFromMidi(value, toValueFrom: state.feedbackRange)
        return "\(Int(value))"
    }
    
    func lowPassCutoffFormat(_ value: MidiValue) -> String {
        let value = convertFromMidi(value, toValueFrom: state.lowPassCutoffRange)
        return "\(Int(value)) Hz"
    }
    
    func dryWetMixFormat(_ value: MidiValue) -> String {
        let value = convertFromMidi(value, toValueFrom: state.dryWetRange)
        return "\(Int(value)) %"
    }
    
    func valueChanged(_ parameter: Parameter, _ value: MidiValue) {
        let control = switch parameter {
        case .delay:
            state.delayCtrl
        case .feedback:
            state.feedbackCtrl
        case .lowPassCutoff:
            state.lowPassCutoffCtrl
        case .dryWetMix:
            state.dryWetMixCtrl
        }
        let controller = MidiControllerId(channel: state.channel, controller: control)
        state.controlChanged(controller, value: value)
    }
}

#Preview {
    let state = DelayControlState(
        initial: DelayControlState.State(),
        channel: 0,
        delayCtrl: 1,
        feedbackCtrl: 2,
        lowPassCutoffCtrl: 3,
        dryWetMixCtrl: 4
    )
    DelayControlView(state: state)
}
