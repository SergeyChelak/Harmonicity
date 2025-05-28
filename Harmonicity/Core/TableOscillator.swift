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
    
    init(sampleRate: Float, table: [Sample]) {
        self.sampleRate = sampleRate
        self.table = table
    }
    
    func setFrequency(_ frequency: Frequency) {
        fatalError()
    }
    
    func nextSample() -> Sample {
        fatalError()
    }
}

// TODO: move to extensions file
extension Float {
    func lerp(_ v1: Self, _ v2: Self) -> Self {
        (1 - self) * v1 + self * v2;
    }
}
