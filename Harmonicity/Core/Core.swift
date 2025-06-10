//
//  Core.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

typealias CoreFloat = Double

protocol CoreProcessor {
    func process(_ sample: CoreFloat) -> CoreFloat
}

protocol CoreNoteStateDriver {
    func noteState() -> NoteState
}

protocol CoreEnvelopeFilter: CoreProcessor, CoreNoteStateDriver {
    //
}

protocol CoreSampleSource {
    func nextSample() -> CoreFloat
}

protocol CoreOscillator: CoreSampleSource {
    func setFrequency(_ frequency: CoreFloat)
}

protocol CoreWaveForm {
    func value(_ x: CoreFloat) -> CoreFloat
    func phaseRange() -> CoreRange
}

extension CoreWaveForm {
    func phaseDuration() -> CoreFloat {
        let p = self.phaseRange()
        return p.upperBound - p.lowerBound
    }
}

protocol CoreOscillatorFactory {
    func oscillator(_ waveForm: CoreWaveForm) -> CoreOscillator
}

protocol CoreVoice: CoreSampleSource, CoreMidiNoteHandler {
    var state: NoteState { get }
    func canPlay(_ note: MidiNote) -> Bool
}

protocol CoreMonoVoice: CoreVoice {
    var noteNumber: MidiNoteNumber { get }
}

protocol CoreMidiNoteHandler {
    func noteOn(_ note: MidiNote)
    func noteOff(_ note: MidiNote)
}

protocol CoreMidiControlChangeHandler {
    func controlChanged(_ controllerId: MidiControllerId, value: MidiValue)
}

enum NoteState {
    case idle
    case play
    case release
    
    var isPlaying: Bool {
        if case(.play) = self {
            return true
        }
        return false
    }
    
    var isReleasing: Bool {
        if case(.release) = self {
            return true
        }
        return false
    }
    
    var isIdle: Bool {
        if case(.idle) = self {
            return true
        }
        return false
    }
}
