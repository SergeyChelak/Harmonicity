//
//  SliderView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

typealias SliderChangeHandler = (MidiValue) -> Void

struct SliderView: View {
    @ObservedObject var viewModel: SliderViewModel
    
    init(
        _ initialValue: CoreFloat,
        destinationRange: Range<CoreFloat>,
        handler: @escaping SliderChangeHandler
    ) {
        viewModel = SliderViewModel(
            value: initialValue,
            destinationRange: destinationRange,
            handler: handler
        )
    }
    
    var body: some View {
        VStack {
            Slider(value: $viewModel.midiValue, in: viewModel.range)
            Text(String(viewModel.formattedValue))
        }
    }
}

final class SliderViewModel: ObservableObject {
    let range = 0...Double(maxMidiValue)
    private let destinationRange: Range<CoreFloat>
    private let handler: SliderChangeHandler
    @Published var midiValue: Double {
        didSet {
            let value = MidiValue(midiValue)
            handler(value)
        }
    }
    
    init(
        value: Double,
        destinationRange: Range<CoreFloat>,
        handler: @escaping SliderChangeHandler
    ) {
        self.midiValue = Double(convertToMidi(value, from: destinationRange))
        self.destinationRange = destinationRange
        self.handler = handler
    }
    
    var formattedValue: String {
        String(Int(midiValue))
    }
}

#Preview {
    SliderView(0, destinationRange: 0..<100.0) { _ in
        // no op
    }
}
