//
//  Voice.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

final class Oscillator {
    var waveform: Waveform
    var weight: Float
    
    init(waveform: Waveform, weight: Float = 1.0) {
        self.waveform = waveform
        self.weight = weight
    }
}


final class Voice {
    private var phase: Float = 0.0
    private var oscillators: [Oscillator]
    
    private(set) var velocity: Float = 0.0
    private var delta: Float = 0.0
    
    var sampleRate: Float = 0.0
    
    init(oscillators: [Oscillator]) {
        self.oscillators = oscillators
    }
    
    func nextSample() -> Float {
        guard sampleRate > 0.0 else {
            return 0
        }
        
        let (sum, totalWeight) = oscillators
            .map {
                (
                    $0.weight * velocity * $0.waveform.value(phase: phase),
                    $0.weight
                )
            }
            .reduce((0, 0)) { acc, val in
                (acc.0 + val.0, acc.1 + val.1)
            }
                
        phase += delta
        if phase >= 2.0 * .pi {
            phase -= 2.0 * .pi
        }
        
        return sum / totalWeight
    }
    
    func play(frequency: Float, velocity: Float) {
        self.phase = 0
        self.velocity = velocity
        self.delta = 2.0 * .pi * frequency / sampleRate
    }
    
    var isPlaying: Bool {
        self.velocity > 0.0
    }

}
