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
    
    private let reverbNode: AVAudioUnitReverb = {
        let node = AVAudioUnitReverb()
        // Configure reverb
        node.loadFactoryPreset(.mediumHall)
        node.wetDryMix = 20.0 
        return node
    }()
        
    deinit {
        stop()
    }
    
    var sampleRate: CoreFloat {
        audioEngine.outputNode.inputFormat(forBus: 0).sampleRate
    }
    
    func setup(_ source: CoreSampleSource) throws {
        let format = audioEngine.outputNode.inputFormat(forBus: 0)
        guard let inputFormat = AVAudioFormat(
            commonFormat: format.commonFormat,
            sampleRate: format.sampleRate,
            channels: 1,
            interleaved: format.isInterleaved
        ) else {
            throw AudioEngineError.formatInitializationFailed
        }
        // ---
        audioEngine.attachAndConnect(reverbNode, to: audioEngine.outputNode, format: nil)
        
        // --
        let sourceNode: AVAudioSourceNode = .withSource(source)
        audioEngine.attachAndConnect(sourceNode, to: reverbNode, format: inputFormat)
    }
    
    func start() throws {
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            throw AudioEngineError.engineStartFailed(error)
        }
    }
    
    func stop() {
        audioEngine.stop()
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

extension AVAudioSourceNode {
    static func withSource(_ source: CoreSampleSource) -> AVAudioSourceNode {
        AVAudioSourceNode { (isSilence, _, frameCount, audioBufferList) -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                let sample = source.nextSample()
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
    }
}
