//
//  OscillatorFactory.swift
//  Harmonicity
//
//  Created by Sergey on 02.07.2025.
//

import Foundation

protocol CoreOscillatorFactory {
    func oscillator(_ waveForm: CoreWaveForm) -> CoreOscillator
}

enum OscillatorFactory {
    case table, function
}

func composeOscillatorFactory(
    factoryType: OscillatorFactory,
    sampleRate: CoreFloat
) -> CoreOscillatorFactory {
    let phaseGenerator = composePhaseGenerator()
    
    let composeTable = {
        TableOscillatorFactory(
            sampleRate: sampleRate,
            tableSize: 64,
            phaseGenerator: phaseGenerator
        )
    }
    
    let composeFunction = {
        WaveOscillatorFactory(
            sampleRate: sampleRate,
            phaseGenerator: phaseGenerator
        )
    }
    
    return switch factoryType {
    case .function: composeFunction()
    case .table: composeTable()
    }
}
