//
//  Synthesizer.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import AVFoundation
import Foundation

final class Synthesizer {
    private let audioEngine = AVAudioEngine()
    
    private let voice: Voice
    
    init() {
        self.voice = Voice(
            oscillators: [
                Oscillator(waveform: .sine, weight: 0.8),
                Oscillator(waveform: .triangle, weight: 0.6),
//                Oscillator(waveform: .sawtooth),
                Oscillator(waveform: .square)
            ]
        )
    }
    
    deinit {
        audioEngine.stop()
    }
        
    func setup() throws {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        self.voice.sampleRate = Float(format.sampleRate)
        
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
        
        let sourceNode = AVAudioSourceNode { [weak voice] (isSilence, _, frameCount, audioBufferList) -> OSStatus in
            guard let voice else {
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
        
        audioEngine.attachAndConnect(
            sourceNode,
            to: oscillatorMixer,
            format: inputFormat
        )

        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // TODO: replace to midi action
    func play(_ action: KeyAction) {
        let freq = action.note.frequency * Float(1 << action.octave)
        print("note: \(action.note), freq: \(freq)")
        let velocity: Float = action.isPressed ? 0.5 : 0.0
        voice.play(frequency: freq, velocity: velocity)
    }
    
    func play(_ data: NoteData) {
        guard data.channel == 0 else {
            return
        }
        let velocity = Float(data.velocity) / 127
        
        // for single voice: don't mute current note if released another one
        if velocity == 0 && voice.note != data.note {
            return
        }
        let freq = 440.0 * pow(2.0, (Float(data.note) - 69.0) / 12.0)
        voice.play(frequency: freq, velocity: velocity)
        voice.note = data.note
    }
    
    func processMidiEvent(_ event: MidiEvent) {
        switch event {
        case .note(let noteData):
            play(noteData)
        }
    }
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
