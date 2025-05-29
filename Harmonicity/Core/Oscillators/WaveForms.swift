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

struct SawtoothWaveForm: CoreWaveForm {
    func value(_ x: Float) -> Float {
        2.0 * x - 1.0
    }
    func phaseRange() -> Range<Float> {
        0..<1.0
    }
}


/*
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

 */
