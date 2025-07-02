//
//  PhaseGenerator.swift
//  Harmonicity
//
//  Created by Sergey on 02.07.2025.
//

import Foundation

protocol PhaseGenerator {
    func value(in range: CoreRange) -> CoreFloat
}

func composePhaseGenerator() -> PhaseGenerator {
    let randomGenerator = RandomNumberGeneratorWithSeed(seed: 1234)
    return CoreRangeGenerator(randomGenerator: randomGenerator)
}

fileprivate final class CoreRangeGenerator: PhaseGenerator {
    private var randomGenerator: RandomNumberGenerator
    
    init(randomGenerator: RandomNumberGenerator) {
        self.randomGenerator = randomGenerator
    }
    
    func value(in range: CoreRange) -> CoreFloat {
        CoreFloat.random(in: range, using: &randomGenerator)
    }
}

fileprivate struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
    init(seed: Int) {
        // Set the random seed
        srand48(seed)
    }
    
    func next() -> UInt64 {
        // drand48() returns a Double, transform to UInt64
        withUnsafeBytes(of: drand48()) { bytes in
            bytes.load(as: UInt64.self)
        }
    }
}
