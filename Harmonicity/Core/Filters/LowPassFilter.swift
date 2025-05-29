//
//  LowPassFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class LowPassFilter: CoreProcessor, CoreMIDINoteHandler {
    private let sampleRate: Float
    var cutoffFrequency: Float {
        didSet {
            updateCoefficients()
        }
    }
    private var alpha: Float = 0.0
    private var previousOutput: Float = 0.0
    
    init(sampleRate: Float, cutoffFrequency: Float = 20_000) {
        self.sampleRate = sampleRate
        self.cutoffFrequency = cutoffFrequency
        updateCoefficients()
    }
    
    func process(_ sample: Sample) -> Sample {
        let output = previousOutput + alpha * (sample - previousOutput)
        previousOutput = output
        return output
    }
    
    private func updateCoefficients() {
        let clampedCutoff = max(1.0, min(cutoffFrequency, sampleRate / 2.0))
        alpha = 1.0 - exp(-2.0 * .pi * clampedCutoff / sampleRate)
    }
    
    func noteOn(_ note: MidiNote) {
        previousOutput = 0.0
    }
    
    func noteOff(_ note: MidiNote) {
        // no op
    }
}
