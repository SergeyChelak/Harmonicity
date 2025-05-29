//
//  TableOscillatorFactory.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class TableOscillatorFactory: CoreOscillatorFactory {
    private let sampleRate: CoreFloat
    private let tableSize: Int
    
    init(sampleRate: CoreFloat, tableSize: Int) {
        self.sampleRate = sampleRate
        self.tableSize = tableSize
    }
    
    func oscillator(_ waveForm: any CoreWaveForm) -> any CoreOscillator {
        let table = makeTable(from: waveForm, tableSize)
        return TableOscillator(sampleRate: sampleRate, table: table)
    }
}

fileprivate func makeTable(from waveForm: CoreWaveForm, _ tableSize: Int) -> [CoreFloat] {
    let size = CoreFloat(tableSize)
    let range = waveForm.phaseRange()
    let duration = range.length
    let offset = range.lowerBound
    var table: [CoreFloat] = []
    for n in 0..<tableSize {
        let value = waveForm.value(duration * CoreFloat(n) / size + offset)
        table.append(value)
    }
    return table
}

