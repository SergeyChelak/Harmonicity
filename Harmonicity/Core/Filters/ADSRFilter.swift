//
//  ADSRFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Atomics
import Foundation

final class ADSRFilter: CoreProcessor, CoreMidiNoteHandler {
    enum Parameter: Hashable {
        case attack, decay, sustain, release
    }
    
    private enum State {
        case idle
        case attack
        case decay
        case sustain
        case release
    }
    
    private struct EnvelopeData {
        var attackTime: CoreFloat
        var decayTime: CoreFloat
        var sustainLevel: CoreFloat
        var releaseTime: CoreFloat
    }

    // MARK: - user controlled envelope parameters
    private var envelopeData: EnvelopeData
    private var pendingEnvelopeData: EnvelopeData
    private var needsUpdate = ManagedAtomic<Bool>(false)
    private var controlMap = MidiControllerMap<Parameter>()
    
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
        let data = EnvelopeData(
            attackTime: attackTime,
            decayTime: decayTime,
            sustainLevel: sustainLevel,
            releaseTime: releaseTime
        )
        self.envelopeData = data
        self.pendingEnvelopeData = data
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
    
    func bind(criteria: MidiControllerIdCriteria, parameter: Parameter) {
        controlMap.insert(criteria: criteria, parameter)
    }
}

extension ADSRFilter: CoreMidiControlChangeHandler {
    func controlChanged(_ control: MidiControllerId, value: MidiValue) {
        let nodes = controlMap.get(by: control)
        fatalError("ADSR not updated for \(nodes)")
//        needsUpdate.store(true, ordering: .releasing)
    }
}
