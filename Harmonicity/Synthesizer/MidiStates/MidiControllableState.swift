//
//  MidiControllableState.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import Combine
import Foundation

class MidiControllableState<T, S: AnyObject>: CoreMidiControlChangeHandler {
    private let subject: CurrentValueSubject<T, Never>
    var publisher: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    private var subscribers: [WeakRef<S>] = []
    
    private var storedValue: T
    
    init(
        initial: T
    ) {
        storedValue = initial
        subject = CurrentValueSubject(initial)
    }
    
    func addSubscriber(_ subscriber: S) {
        subscribers.append(WeakRef(value: subscriber))
    }
    
    func isSubscribed(to controllerId: MidiControllerId) -> Bool {
        fatalError("`isSubscribed` must be overridden in children")
    }
    
    func controlChanged(_ controllerId: MidiControllerId, value: MidiValue) {
        guard isSubscribed(to: controllerId) else {
            return
        }
        guard let value = map(controllerId, midiValue: value, stored: storedValue) else {
            return
        }
        subscribers
            .compactMap {
                $0.value
            }
            .forEach {
                update($0, with: value)
            }
        self.storedValue = value
        subject.send(value)
    }
    
    func map(_ controllerId: MidiControllerId, midiValue: MidiValue, stored: T) -> T? {
        fatalError("`map` must be overridden in children")
    }
    
    func update(_ obj: S, with value: T) {
        fatalError("`update` must be overridden in children")
    }
}
