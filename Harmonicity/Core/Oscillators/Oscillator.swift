//
//  Oscillator.swift
//  Harmonicity
//
//  Created by Sergey on 31.05.2025.
//

import Atomics
import Foundation

class Oscillator<T>: CoreOscillator {
    private var parameters: T
    private var pendingParameters: T
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    init(_ initial: T) {
        self.parameters = initial
        self.pendingParameters = initial
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        pendingParameters = pendingParameters(frequency)
        needsUpdate.store(true, ordering: .releasing)
    }
    
    func pendingParameters(_ frequency: CoreFloat) -> T {
        fatalError("pendingParameters must be implemented in children")
    }
    
    func nextSample() -> CoreFloat {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            parameters = pendingParameters
        }
        return generateSample(&parameters)
    }
    
    func generateSample(_ parameters: inout T) -> CoreFloat {
        fatalError("generateSample must be implemented in children")
    }
}
