//
//  DetuneControlView.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

struct DetuneControlView: View {
//    private let state: DetunedOscillatorState
//    private let controlIds: MidiControllerId
    
    var body: some View {
        SliderView(0, destinationRange: 0..<1000, handler: {_ in})
    }
}

#Preview {
    DetuneControlView()
}
