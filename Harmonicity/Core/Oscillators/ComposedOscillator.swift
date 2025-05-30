//
//  ComposedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 30.05.2025.
//

import Foundation

final class ComposedOscillator: CoreOscillator {
    private let oscillators: [CoreOscillator]
    
    init(oscillators: [CoreOscillator]) {
        self.oscillators = oscillators
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        oscillators.forEach {
            $0.setFrequency(frequency)
        }
    }
    
    func nextSample() -> CoreFloat {
        oscillators
            .map { $0.nextSample() }
            .reduce(0.0) { $0 + $1 } / CoreFloat(oscillators.count)
    }
}
