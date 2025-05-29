//
//  WaveForms.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

struct SineWaveForm: CoreWaveForm {
    func value(_ x: Float) -> Float {
        sin(x)
    }
    func phaseRange() -> Range<Float> {
        0..<2 * .pi
    }
}

struct SquareWaveForm: CoreWaveForm {
    func value(_ x: Float) -> Float {
        x < 0.5 ? 1.0 : -1.0
    }
    func phaseRange() -> Range<Float> {
        0..<1.0
    }
}
