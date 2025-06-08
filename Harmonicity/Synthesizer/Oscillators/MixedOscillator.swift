//
//  MixedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Atomics
import Foundation

class MixedOscillator: CoreOscillator {
    typealias SourceIndex = Int

    private var sources: [CoreOscillator]
    private var weights: [CoreFloat]
    private var pendingWeights: [CoreFloat]
    private var needsUpdate = ManagedAtomic<Bool>(false)

    init(
        oscillators: [CoreOscillator],
        weights: [CoreFloat]
    ) {
        self.weights = weights
        self.pendingWeights = weights
        self.sources = oscillators
    }
                
    func setFrequency(_ frequency: CoreFloat) {
        sources.forEach {
            $0.setFrequency(frequency)
        }
    }
    
    func nextSample() -> CoreFloat {
        applyUpdate()
        let (totalWeight, mixedSample) = zip(weights, sources)
            .reduce((0, 0)) { acc, val in
                let (weight, source) = val
                return (
                    acc.0 + weight,
                    acc.1 + weight * source.nextSample()
                )
            }
        return totalWeight > 0.0 ? mixedSample / totalWeight : 0.0
    }
    
    private func applyUpdate() {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            weights = pendingWeights
        }
    }
    
    func setWeights(_ val: [CoreFloat]) {
        pendingWeights = val
        needsUpdate.store(true, ordering: .releasing)
    }
}
