//
//  MidiControllerIdCriteria.swift
//  Harmonicity
//
//  Created by Sergey on 06.06.2025.
//

import Foundation

struct MidiControllerIdCriteria: Hashable {
    let channel: MidiChannel?
    let controller: MidiController?
    
    init(
        channel: MidiChannel? = nil,
        controller: MidiController? = nil
    ) {
        self.channel = channel
        self.controller = controller
    }
    
    func matches(_ controllerId: MidiControllerId) -> Bool {
        if let channel, channel != controllerId.channel {
            return false
        }
        
        if let controller, controller != controllerId.controller {
            return false
        }
        
        return true
    }
}

struct MidiControllerMap<T> {
    private var storage: [(MidiControllerIdCriteria, T)] = []
    
    mutating func insert(criteria: MidiControllerIdCriteria, _ value: T) {
        storage.append((criteria, value))
    }
        
    func get(by controllerId: MidiControllerId) -> [T] {
        storage
            .filter { (criteria, _) in criteria.matches(controllerId) }
            .map { (_, value) in value }
    }
}
