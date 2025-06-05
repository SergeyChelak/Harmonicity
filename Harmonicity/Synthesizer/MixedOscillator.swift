//
//  MixedOscillator.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Atomics
import Foundation

class MixedOscillator: CoreOscillator {
    typealias SourceIndex = Int
    
    private var sources: [CoreOscillator] = []
    private var weights: [CoreFloat] = []
    private var pendingWeights: [CoreFloat] = []
    private var controllerMap = MidiControllerMap<SourceIndex>()
    private var needsUpdate = ManagedAtomic<Bool>(false)
    
    func addSource(
        _ source: CoreOscillator,
        weight: CoreFloat = 1.0,
        controller: MidiController? = nil
    ) -> SourceIndex {
        let sourceId = sources.count
        weights.append(weight)
        pendingWeights.append(weight)
        sources.append(source)
        return sourceId
    }
    
    func bind(criteria: MidiControllerIdCriteria, source: SourceIndex) {
        controllerMap.insert(criteria: criteria, source)
    }
    
    func setFrequency(_ frequency: CoreFloat) {
        sources.forEach {
            $0.setFrequency(frequency)
        }
    }
    
    func nextSample() -> CoreFloat {
        let (totalWeight, mixedSample) = zip(weights, sources)
            .reduce((0, 0)) { acc, val in
                let (weight, source) = val
                return (
                    acc.0 + weight,
                    acc.1 + weight * source.nextSample()
                )
            }
        return totalWeight > 0.0 ? mixedSample / totalWeight : 0.0
    }
    
    private func applyUpdate() {
        if needsUpdate.compareExchange(
            expected: true,
            desired: false,
            ordering: .acquiring
        ).exchanged {
            weights = pendingWeights
        }

    }
}

extension MixedOscillator: CoreMidiControlChangeHandler {
    func controlChanged(_ control: MidiControllerId, value: MidiValue) {
        let channels = controllerMap.get(by: control)
        if channels.isEmpty {
            return
        }
        assert(channels.count == 1)
        channels.forEach { pendingWeights[$0] = CoreFloat(value) }
        needsUpdate.store(true, ordering: .releasing)
    }
}
