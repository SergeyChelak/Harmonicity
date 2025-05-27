//
//  Waveform.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import Foundation

enum Waveform {
    case sine, square, sawtooth, triangle

    func value(phase: Float) -> Float {
        switch self {
        case .sine:
            return sin(phase)
        case .square:
            return sin(phase) >= 0 ? 1.0 : -1.0
        case .sawtooth:
            return 2.0 * (phase / (2.0 * .pi)) - 1.0
        case .triangle:
            return abs(4.0 * (phase / (2.0 * .pi) - floor(phase / (2.0 * .pi) + 0.5))) * 2.0 - 1.0
        }
    }
}
