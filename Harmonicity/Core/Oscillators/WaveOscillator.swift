//
//  WaveOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation
import Atomics

class WaveOscillator: CoreOscillator {
    private struct Data {
        var phase: CoreFloat
        var delta: CoreFloat
        
        static let `default` = Data(
            phase: 0.0,
            delta: 0.0
        )
    }
    
    private let sampleRate: CoreFloat
    private let waveForm: CoreWaveForm
    
    private var data: Data = .default
    private var pendingData: Data = .default
    private var needsUpdate = ManagedAtomic<Bool>(false)

    // cache
    private let range: Range<CoreFloat>
        
    init(sampleRate: CoreFloat, waveForm: CoreWaveForm) {
        self.sampleRate = sampleRate
        self.waveForm = waveForm
        self.range = waveForm.phaseRange()
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        pendingData.phase = range.lowerBound
        pendingData.delta = range.length * frequency / sampleRate
        needsUpdate.store(true, ordering: .releasing)
    }
    
    func nextSample() -> CoreFloat {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            data = pendingData
        }
        let sample = waveForm.value(data.phase)
        data.phase += data.delta
        if data.phase >= range.upperBound {
            data.phase -= range.length
        }
        return sample
    }
}
