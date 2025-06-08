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
            
    deinit {
        stop()
    }
    
    var sampleRate: CoreFloat {
        audioEngine.outputNode.inputFormat(forBus: 0).sampleRate
    }
    
    func setup(
        _ source: CoreSampleSource,
        _ states: MidiPostProcessControlStates
    ) throws {
        // ---
        let reverbNode: AVAudioUnitReverb = .withState(states.reverbControlState)
        audioEngine.attachAndConnect(reverbNode, to: audioEngine.outputNode, format: nil)
        
        // --
        let delayNode: AVAudioUnitDelay = .withState(states.delayControlState)
        audioEngine.attachAndConnect(delayNode, to: reverbNode, format: nil)
        
        // --
        let sourceNode: AVAudioSourceNode = .withSource(source)
        audioEngine.attachAndConnect(sourceNode, to: delayNode, format: nil)
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

extension AVAudioUnitReverb {
    static func withState(_ state: ReverbControlState) -> AVAudioUnitReverb {
        let node = AVAudioUnitReverb()
        state.addSubscriber(node)
        state.update(node, with: state.storedValue)
        return node
    }
}

extension AVAudioUnitDelay {
    static func withState(_ state: DelayControlState) -> AVAudioUnitDelay {
        let node = AVAudioUnitDelay()
        state.addSubscriber(node)
        state.update(node, with: state.storedValue)
        return node
    }
}
