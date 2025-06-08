//
//  ReverbControlView.swift
//  Harmonicity
//
//  Created by Sergey on 08.06.2025.
//

import Combine
import SwiftUI

struct ReverbControlView: View {
    @ObservedObject private var viewModel: ReverbControlViewModel
    
    init(state: ReverbControlState) {
        self.viewModel = ReverbControlViewModel(state: state)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text("Preset")
                SwitcherView(
                    items: viewModel.presets,
                    selected: viewModel.presetNumber,
                    handler: viewModel.presetChanged
                )
            }
            
            VStack {
                Text("Dry/Wet Mix")
                SliderView(
                    viewModel.dryWetMix,
                    formatter: viewModel.dryWetFormat(_:),
                    handler: viewModel.dryWetChanged(_:)
                )
            }
        }
    }
}

final class ReverbControlViewModel: ObservableObject {
    private var cancellable: AnyCancellable?
    private let state: ReverbControlState
    @Published var presetNumber: Int = 0
    @Published var dryWetMix: CoreFloat = 0
    
    init(state: ReverbControlState) {
        self.state = state
        self.cancellable = state.publisher.sink { [weak self] in
            self?.presetNumber = $0.preset
            self?.dryWetMix = CoreFloat(convertToMidi($0.wetDryMix, from: state.dryWetRange))
        }
    }
    
    var presets: [SwitcherContent] {
        state.presets.map {
            let title = switch $0 {
            case .cathedral: "Cathedral"
            case .largeChamber: "Large Chamber"
            case .largeHall: "Large Hall"
            case .largeHall2: "Large Hall 2"
            case .largeRoom: "Large Room"
            case .largeRoom2: "Large Room 2"
            case .mediumChamber: "Medium Chamber"
            case .mediumHall: "Medium Hall"
            case .mediumHall2: "Medium Hall 2"
            case .mediumHall3: "Medium Hall 3"
            case .mediumRoom: "Medium Room"
            case .plate: "Plate"
            case .smallRoom: "Small Room"
            @unknown default:
                "Unknown"
            }
            return .text(title)
        }
    }
    
    func presetChanged(_ index: Int) {
        let controlId = MidiControllerId(
            channel: state.channel,
            controller: state.presetCtrl
        )
        state.controlChanged(controlId, value: MidiValue(index))
    }
    
    func dryWetChanged(_ value: MidiValue) {
        let controlId = MidiControllerId(
            channel: state.channel,
            controller: state.dryWetMixCtrl
        )
        state.controlChanged(controlId, value: value)
    }
    
    func dryWetFormat(_ value: MidiValue) -> String {
        let value = convertFromMidi(value, toValueFrom: state.dryWetRange)
        return "\(Int(value)) %"
    }
}

#Preview {
    let initial = ReverbControlState.State(preset: 0, wetDryMix: 20)
    let state = ReverbControlState(
        initial: initial,
        presets: [.cathedral, .largeChamber],
        channel: 0,
        presetCtrl: 1,
        dryWetMixCtrl: 2
    )
    ReverbControlView(state: state)
}
