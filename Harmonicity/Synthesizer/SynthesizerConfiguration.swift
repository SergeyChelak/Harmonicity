//
//  SynthesizerConfiguration.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Foundation

struct SynthesizerConfiguration {
    var voices: Int { 8 }
    
    var rootOscillatorsCount: Int { 3 }
    
    var waveForms: [KnownWaveForm] {
        [.sine, .sawtooth, .triangle, .square]
    }
}

enum KnownWaveForm {
    case sine, square, triangle, sawtooth
    
    func instance() -> CoreWaveForm {
        switch self {
        case .sine:
            Self.sineWaveForm
        case .square:
            Self.squareWaveForm
        case .triangle:
            Self.triangleWaveForm
        case .sawtooth:
            Self.sawtoothWaveForm
        }
    }
    
    private static let sineWaveForm = SineWaveForm()
    private static let squareWaveForm = SquareWaveForm()
    private static let triangleWaveForm = TriangleWaveForm()
    private static let sawtoothWaveForm = SawtoothWaveForm()
}
