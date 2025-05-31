//
//  WaveForms.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

struct SineWaveForm: CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat {
        sin(x)
    }
    func phaseRange() -> Range<CoreFloat> {
        0..<2 * .pi
    }
}

struct SquareWaveForm: CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat {
        x < 0.5 ? 1.0 : -1.0
    }
    func phaseRange() -> Range<CoreFloat> {
        0..<1.0
    }
}

struct SawtoothWaveForm: CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat {
        2.0 * x - 1.0
    }
    func phaseRange() -> Range<CoreFloat> {
        0..<1.0
    }
}

struct TriangleWaveForm: CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat {
        2.0 * abs(2.0 * x - 1.0) - 1.0
    }
    func phaseRange() -> Range<CoreFloat> {
        0..<1.0
    }
}
