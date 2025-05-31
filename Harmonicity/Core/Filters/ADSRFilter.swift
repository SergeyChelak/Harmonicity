//
//  ADSRFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class ADSRFilter: CoreProcessor, CoreMidiNoteHandler {
    private enum State {
        case idle
        case attack
        case decay
        case sustain
        case release
    }

    // MARK: - user controlled envelope parameters
    var attackTime: CoreFloat
    var decayTime: CoreFloat
    var sustainLevel: CoreFloat
    var releaseTime: CoreFloat

    // MARK: - envelope state
    private var currentState: State = .idle
    private var currentLevel: CoreFloat = 0.0    // 0.0 - 1.0
    private var segmentProgress: CoreFloat = 0.0 // 0.0 - 1.0
    private var startLevel: CoreFloat = 0.0
    private let sampleRate: CoreFloat
    private var noteNumber: MidiNoteNumber = .max

    init(
        sampleRate: CoreFloat,
        attackTime: CoreFloat = 0.01,
        decayTime: CoreFloat = 0.1,
        sustainLevel: CoreFloat = 0.7,
        releaseTime: CoreFloat = 0.2
    ) {
        self.sampleRate = sampleRate
        self.attackTime = attackTime
        self.decayTime = decayTime
        self.sustainLevel = sustainLevel
        self.releaseTime = releaseTime
    }

    func noteOn(_ note: MidiNote) {
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
    
    func process(_ sample: CoreFloat) -> CoreFloat {
        level() * sample
    }

    private func level() -> CoreFloat {
        switch currentState {
        case .idle:
            currentLevel = 0.0
            return currentLevel

        case .attack:
            let attackDurationSamples = max(1.0, attackTime * sampleRate)
            segmentProgress += 1.0 / attackDurationSamples
            // lerp form startLevel to 1.0
            currentLevel = startLevel + (1.0 - startLevel) * min(1.0, segmentProgress)
            if segmentProgress >= 1.0 {
                currentState = .decay
                startLevel = currentLevel
                segmentProgress = 0.0
            }

        case .decay:
            let decayDurationSamples = max(1.0, decayTime * sampleRate)
            segmentProgress += 1.0 / decayDurationSamples
            // lerp from startLevel to sustainLevel
            currentLevel = startLevel + (sustainLevel - startLevel) * min(1.0, segmentProgress)
            
            if segmentProgress >= 1.0 {
                currentState = .sustain
                currentLevel = sustainLevel
            }

        case .sustain:
            // constant sustain
            currentLevel = sustainLevel

        case .release:
            let releaseDurationSamples = max(1.0, releaseTime * sampleRate)
            segmentProgress += 1.0 / releaseDurationSamples

            // lerp from startLevel to 0.0, fade to 0.0
            currentLevel = startLevel * (1.0 - min(1.0, segmentProgress))

            if segmentProgress >= 1.0 {
                reset()
            }
        }
        return currentLevel
    }
}
