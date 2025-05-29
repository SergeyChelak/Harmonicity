//
//  TableOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class TableOscillator: CoreOscillator {
    private let sampleRate: CoreFloat
    private let table: [CoreFloat]
    
    // TODO: check if float is good approach
    private var index: CoreFloat = 0.0
    private var step: CoreFloat = 0.0
    
    // cache
    private let size: CoreFloat
    
    init(sampleRate: CoreFloat, table: [CoreFloat]) {
        self.sampleRate = sampleRate
        self.table = table
        self.size = CoreFloat(table.count)
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        self.index = 0
        self.step = frequency * size / sampleRate
    }
    
    func nextSample() -> CoreFloat {
        let sample = self.lerp()
        self.index = (self.index + step).truncatingRemainder(dividingBy: size)
        return sample
    }
    
    private func lerp() -> CoreFloat {
        let truncatedIndex = Int(index)
        let nextIndex = (truncatedIndex + 1) % table.count
        let nextIndexWeight = index - CoreFloat(truncatedIndex)
        let truncatedIndexWeight = 1.0 - nextIndexWeight
        return truncatedIndexWeight * table[truncatedIndex] + nextIndexWeight * table[nextIndex]
    }
}
