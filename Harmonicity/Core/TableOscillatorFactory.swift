//
//  TableOscillatorFactory.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class TableOscillatorFactory: CoreOscillatorFactory {
    private let sampleRate: Float
    private let tableSize: Int
    
    init(sampleRate: Float, tableSize: Int) {
        self.sampleRate = sampleRate
        self.tableSize = tableSize
    }
    
    func oscillator(_ waveForm: any CoreWaveForm) -> any CoreOscillator {
        let table = makeTable(from: waveForm, tableSize)
        return TableOscillator(sampleRate: sampleRate, table: table)
    }
}

fileprivate func makeTable(from waveForm: CoreWaveForm, _ tableSize: Int) -> [Float] {
    let size = Float(tableSize)
    let period = waveForm.period()
    let duration = period.length
    let offset = period.lowerBound
    var table: [Float] = []
    for n in 0..<tableSize {
        let value = waveForm.value(duration * Float(n) / size + offset)
        table.append(value)
    }
    return table
}

