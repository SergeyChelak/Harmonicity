//
//  SliderView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

typealias SliderChangeHandler = (MidiValue) -> Void
typealias SliderValueFormatter = (MidiValue) -> String

struct SliderView: View {
    @ObservedObject var viewModel: SliderViewModel
    private let formatter: SliderValueFormatter
    
    init(
        _ initialValue: CoreFloat,
        formatter: @escaping SliderValueFormatter = defaultSliderValueFormatter,
        handler: @escaping SliderChangeHandler
    ) {
        self.viewModel = SliderViewModel(
            value: initialValue,
            handler: handler
        )
        self.formatter = formatter
    }
    
    var body: some View {
        VStack {
            Slider(value: $viewModel.midiValue, in: viewModel.range)
            Text(formatter(MidiValue(viewModel.midiValue)))
        }
    }
}

final class SliderViewModel: ObservableObject {
    let range = 0...Double(maxMidiValue)
    private let handler: SliderChangeHandler
    @Published var midiValue: Double {
        didSet {
            let value = MidiValue(midiValue)
            handler(value)
        }
    }
    
    init(
        value: Double,
        handler: @escaping SliderChangeHandler
    ) {
        self.midiValue = value
        self.handler = handler
    }
    
}

fileprivate func defaultSliderValueFormatter(_ value: MidiValue) -> String {
    "Midi \(Int(value))"
}

#Preview {
    SliderView(0) { _ in
        // no op
    }
}
