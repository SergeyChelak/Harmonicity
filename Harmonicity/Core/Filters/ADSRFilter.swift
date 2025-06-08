//
//  ADSRFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Atomics
import Foundation

final class ADSRFilter: CoreProcessor, CoreMidiNoteHandler {    
    private enum State {
        case idle
        case attack
        case decay
        case sustain
        case release
    }
    
    struct EnvelopeData {
        var attackTime: CoreFloat = 0.01
        var decayTime: CoreFloat = 0.1
        var sustainLevel: CoreFloat = 0.7
        var releaseTime: CoreFloat = 0.01
    }

    // MARK: - user controlled envelope parameters
    private var envelopeData: EnvelopeData
    private var pendingEnvelopeData: EnvelopeData
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    // MARK: - envelope state
    private var currentState: State = .idle
    private var currentLevel: CoreFloat = 0.0    // 0.0 - 1.0
    private var segmentProgress: CoreFloat = 0.0 // 0.0 - 1.0
    private var startLevel: CoreFloat = 0.0
    private let sampleRate: CoreFloat
    private var noteNumber: MidiNoteNumber = .max
    
    init(
        sampleRate: CoreFloat,
        envelope: EnvelopeData
    ) {
        self.sampleRate = sampleRate
        self.envelopeData = envelope
        self.pendingEnvelopeData = envelope
    }

    func noteOn(_ note: MidiNote) {
        applyUpdate()
        noteNumber = note.note
        startLevel = currentLevel
        segmentProgress = 0.0
        currentState = .attack
    }

    func noteOff(_ note: MidiNote) {
        // don't start release phase for other released notes
        guard note.note == noteNumber else {
            return
        }
        startLevel = currentLevel
        segmentProgress = 0.0
        currentState = .release
    }
    
    private func reset() {
        noteNumber = .max
        currentState = .idle
        currentLevel = 0.0
        segmentProgress = 0.0
        startLevel = 0.0
    }
    
    private func applyUpdate() {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            envelopeData = pendingEnvelopeData
        }
    }
    
    func process(_ sample: CoreFloat) -> CoreFloat {
        level() * sample
    }

    private func level() -> CoreFloat {
        switch currentState {
        case .idle:
            currentLevel = 0.0
            return currentLevel

        case .attack:
            let attackDurationSamples = max(1.0, envelopeData.attackTime * sampleRate)
            segmentProgress += 1.0 / attackDurationSamples
            // lerp form startLevel to 1.0
            currentLevel = startLevel + (1.0 - startLevel) * min(1.0, segmentProgress)
            if segmentProgress >= 1.0 {
                currentState = .decay
                startLevel = currentLevel
                segmentProgress = 0.0
            }

        case .decay:
            let decayDurationSamples = max(1.0, envelopeData.decayTime * sampleRate)
            segmentProgress += 1.0 / decayDurationSamples
            // lerp from startLevel to sustainLevel
            currentLevel = startLevel + (envelopeData.sustainLevel - startLevel) * min(1.0, segmentProgress)
            
            if segmentProgress >= 1.0 {
                currentState = .sustain
                currentLevel = envelopeData.sustainLevel
            }

        case .sustain:
            // constant sustain
            currentLevel = envelopeData.sustainLevel

        case .release:
            let releaseDurationSamples = max(1.0, envelopeData.releaseTime * sampleRate)
            segmentProgress += 1.0 / releaseDurationSamples

            // lerp from startLevel to 0.0, fade to 0.0
            currentLevel = startLevel * (1.0 - min(1.0, segmentProgress))

            if segmentProgress >= 1.0 {
                reset()
            }
        }
        return currentLevel
    }

    func setEnvelope(_ envelope: EnvelopeData) {
        pendingEnvelopeData = envelope
        needsUpdate.store(true, ordering: .releasing)
    }
}
