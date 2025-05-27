//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import AVFoundation
import Foundation

final class Oscillator {
    private(set) var waveform: Waveform
    private(set) var phase: Float = 0.0
    
    private(set) var frequency: Float = 0.0
    private(set) var velocity: Float = 0.0
    
    var sampleRate: Float = 0.0
    
    init(waveform: Waveform) {
        self.waveform = waveform
    }
    
    func set(frequency: Float, velocity: Float) {
        self.phase = 0
        self.frequency = frequency
        self.velocity = velocity
    }
    
    func mute() {
        set(frequency: 0, velocity: 0)
    }
    
    func nextSample() -> Float {
        guard sampleRate > 0.0 else {
            return 0
        }
        let result = velocity * waveform.value(phase: phase)
        let delta = 2.0 * .pi * frequency / sampleRate
        phase += delta
        if phase >= 2.0 * .pi {
            phase -= 2.0 * .pi
        }
        return result
    }
}

final class Synthesizer {
    private let audioEngine = AVAudioEngine()
    
    private let oscillators: [Oscillator]
    
    init() {
        let sine = Oscillator(waveform: .sine)
        sine.set(frequency: 440 / 2, velocity: 0.5)
        
        let sine1 = Oscillator(waveform: .triangle)
        sine1.set(frequency: 3 * 440, velocity: 0.5)
        self.oscillators = [
            sine,
            sine1
        ]
    }
    
    deinit {
        audioEngine.stop()
    }
        
    func setup() throws {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        // setup oscillators
        oscillators.forEach {
            $0.sampleRate = Float(format.sampleRate)
        }
        
        guard let inputFormat = AVAudioFormat(
            commonFormat: format.commonFormat,
            sampleRate: format.sampleRate,
            channels: 1,
            interleaved: format.isInterleaved
        ) else {
            throw NSError(domain: "Synthesizer", code: -2)
        }
        
        let oscillatorMixer = AVAudioMixerNode()
        audioEngine.attachAndConnect(
            oscillatorMixer,
            to: audioEngine.outputNode,
            format: inputFormat
        )
        
        for oscillator in oscillators {
            let sourceNode = AVAudioSourceNode { [weak oscillator] (isSilence, _, frameCount, audioBufferList) -> OSStatus in
                guard let oscillator else {
                    isSilence.pointee = true
                    return noErr
                }
                let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                for frame in 0..<Int(frameCount) {
                    let sample = oscillator.nextSample()
                    for buffer in ablPointer {
                        guard let pointer = buffer.mData?.assumingMemoryBound(to: Float.self) else {
                            continue
                        }
                        pointer[frame] = sample
                    }
                }
                
                isSilence.pointee = false
                return noErr
            }
            
            audioEngine.attachAndConnect(
                sourceNode,
                to: oscillatorMixer,
                format: inputFormat
            )
        }

        audioEngine.prepare()
        try audioEngine.start()
    }
}

fileprivate extension AVAudioEngine {
    func attachAndConnect(_ node: AVAudioNode, to node2: AVAudioNode, format: AVAudioFormat?) {
        attach(node)
        connect(node, to: node2, format: format)
    }
}
