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
    // TODO: temporary
    private var sampleSource: CoreVoice?

    deinit {
        audioEngine.stop()
    }

    
    init() {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate)
//        let oscillator = WaveOscillator(
//            sampleRate: sampleRate,
//            waveForm: SquareWaveForm()
//        )
        let factory = TableOscillatorFactory(
            sampleRate: sampleRate,
            tableSize: 64
        )
        let oscillator = factory.oscillator(SineWaveForm())
        self.sampleSource = SimpleVoice(oscillator: oscillator)
    }
    
    func setup() throws {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
//        self.voice.sampleRate = Float(format.sampleRate)
                        
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
        
        guard let inputFormat = AVAudioFormat(
            commonFormat: format.commonFormat,
            sampleRate: format.sampleRate,
            channels: 1,
            interleaved: format.isInterleaved
        ) else {
//            throw NSError(domain: "Synthesizer", code: -2)
            return
        }
        audioEngine.attachAndConnect(
            sourceNode,
            to: audioEngine.outputNode,
            format: inputFormat
        )

        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // TODO: replace to midi action
//    func play(_ action: KeyAction) {
//        let freq = action.note.frequency * Float(1 << action.octave)
//        print("note: \(action.note), freq: \(freq)")
//        let velocity: Float = action.isPressed ? 0.5 : 0.0
//        voice.play(frequency: freq, velocity: velocity)
//    }
    
    // TODO: move out this class
    func play(_ data: NoteData) {
        guard data.channel == 0 else {
            return
        }
        self.sampleSource?.play(data)
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
