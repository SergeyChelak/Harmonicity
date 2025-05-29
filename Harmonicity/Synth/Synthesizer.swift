//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import AVFoundation
import Foundation

func composeVoice(sampleRate: Float) -> CoreVoice {
    let squareOscillator = WaveOscillator(
        sampleRate: sampleRate,
        waveForm: SquareWaveForm()
    )
    
    let sineOscillator = WaveOscillator(
        sampleRate: sampleRate,
        waveForm: SineWaveForm()
    )
    
    let multiVoice = MultiVoice(oscillators: [
        squareOscillator,
        DetunedOscillator(
            oscillator: sineOscillator,
            detune: 15
        ),
        DetunedOscillator(
            oscillator: sineOscillator,
            detune: -15
        )
    ])
    
//    let envelopeFilter = ADSRFilter(sampleRate: sampleRate)
    
    let voiceChain = VoiceChain(voice: multiVoice)
    voiceChain.chain(LowPassFilter(sampleRate: sampleRate, cutoffFrequency: 10_000))
//    voiceChain.chain(envelopeFilter)
    voiceChain.chain(ClipFilter(minimum: -1.0, maximum: 1.0))
    return voiceChain
}


final class Synthesizer {
    private let audioEngine = AVAudioEngine()
    // TODO: temporary
    private var sampleSource: CoreVoice?

    deinit {
        audioEngine.stop()
    }

    
    init() {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate)

        self.sampleSource = composeVoice(sampleRate: sampleRate)
    }
    
    func setup() throws {
        let sourceNode = AVAudioSourceNode { [weak self] (isSilence, _, frameCount, audioBufferList) -> OSStatus in
            guard let voice = self?.sampleSource else {
                isSilence.pointee = true
                return noErr
            }
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = voice.nextSample()
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
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        guard let inputFormat = AVAudioFormat(
            commonFormat: format.commonFormat,
            sampleRate: format.sampleRate,
            channels: 1,
            interleaved: format.isInterleaved
        ) else {
            throw NSError(domain: "Synthesizer", code: -2)
        }
        audioEngine.attachAndConnect(
            sourceNode,
            to: audioEngine.outputNode,
            format: inputFormat
        )

        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // TODO: move out this class ------------
    func play(_ data: MIDINote) {
        self.sampleSource?.play(data)
    }
    
    func processMidiEvent(_ event: MidiEvent) {
        switch event {
        case .note(let channel, let note):
            if channel == 0 {
                play(note)
            }
        }
    }
    // TODO: end ----------------------------
}

fileprivate extension AVAudioEngine {
    func attachAndConnect(
        _ node: AVAudioNode,
        to node2: AVAudioNode,
        format: AVAudioFormat?
    ) {
        attach(node)
        connect(node, to: node2, format: format)
    }
}
