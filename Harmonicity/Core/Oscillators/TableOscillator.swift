//
//  TableOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class TableOscillator: CoreOscillator {
    private let sampleRate: Float
    private let table: [Sample]
    
    // TODO: check if float is good approach
    private var index: Float = 0.0
    private var step: Float = 0.0
    
    // cache
    private let size: Float
    
    init(sampleRate: Float, table: [Sample]) {
        self.sampleRate = sampleRate
        self.table = table
        self.size = Float(table.count)
    }
    
    func setFrequency(_ frequency: Frequency) {
        self.index = 0
        self.step = frequency * size / sampleRate
    }
    
    func nextSample() -> Sample {
        let sample = self.lerp()
        self.index = (self.index + step).truncatingRemainder(dividingBy: size)
        return sample
    }
    
    private func lerp() -> Sample {
        let truncatedIndex = Int(index)
        let nextIndex = (truncatedIndex + 1) % table.count
        let nextIndexWeight = index - Float(truncatedIndex)
        let truncatedIndexWeight = 1.0 - nextIndexWeight
        return truncatedIndexWeight * table[truncatedIndex] + nextIndexWeight * table[nextIndex]
    }
}
