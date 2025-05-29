//
//  AudioEngine.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import AVFoundation
import Foundation

enum AudioEngineError: Error {
    case formatInitializationFailed
    case engineStartFailed(Error)
}

final class AudioEngine {
    private let audioEngine = AVAudioEngine()
    var sampleSource: CoreSampleSource?
        
    deinit {
        audioEngine.stop()
    }
    
    var sampleRate: CoreFloat {
        audioEngine.outputNode.inputFormat(forBus: 0).sampleRate
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
                    pointer[frame] = Float(sample)
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
            throw AudioEngineError.formatInitializationFailed
        }
        audioEngine.attachAndConnect(
            sourceNode,
            to: audioEngine.outputNode,
            format: inputFormat
        )

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            throw AudioEngineError.engineStartFailed(error)
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
