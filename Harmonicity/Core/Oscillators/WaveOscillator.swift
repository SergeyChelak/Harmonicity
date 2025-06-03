//
//  WaveOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation
import Atomics

class WaveOscillator: Oscillator<WaveOscillator.Data> {
    struct Data {
        var phase: CoreFloat = 0.0
        var delta: CoreFloat = 0.0
    }
    
    private let sampleRate: CoreFloat
    private let waveForm: CoreWaveForm
    
    // cache
    private let range: Range<CoreFloat>
        
    init(sampleRate: CoreFloat, waveForm: CoreWaveForm) {
        self.sampleRate = sampleRate
        self.waveForm = waveForm
        self.range = waveForm.phaseRange()
        super.init(Data())
    }
    
    override func pendingParameters(_ frequency: CoreFloat) -> Data {
        Data(
            phase: range.lowerBound,
            delta: range.length * frequency / sampleRate
        )
    }
    
    override func generateSample(_ data: inout Data) -> CoreFloat {
        let sample = waveForm.value(data.phase)
        data.phase += data.delta
        if data.phase >= range.upperBound {
            data.phase -= range.length
        }
        return sample
    }
}
