//
//  TableOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

class TableOscillator: Oscillator<TableOscillator.Data> {
    struct Data {
        var index: CoreFloat = 0.0
        var step: CoreFloat = 0.0
    }

    private let sampleRate: CoreFloat
    private let table: [CoreFloat]
    
    // cache
    private let size: CoreFloat
    
    init(sampleRate: CoreFloat, table: [CoreFloat]) {
        self.sampleRate = sampleRate
        self.table = table
        self.size = CoreFloat(table.count)
        super.init(Data())
    }
    
    override func pendingParameters(_ frequency: CoreFloat) -> Data {
        Data(
            index: 0,
            step: frequency * size / sampleRate
        )
    }
    
    override func generateSample(_ parameters: inout Data) -> CoreFloat {
        let sample = lerp(parameters)
        parameters.index = (parameters.index + parameters.step).truncatingRemainder(dividingBy: size)
        return sample
    }
    
    private func lerp(_ data: Data) -> CoreFloat {
        let truncatedIndex = Int(data.index)
        let nextIndex = (truncatedIndex + 1) % table.count
        let nextIndexWeight = data.index - CoreFloat(truncatedIndex)
        let truncatedIndexWeight = 1.0 - nextIndexWeight
        return truncatedIndexWeight * table[truncatedIndex] + nextIndexWeight * table[nextIndex]
    }
}
