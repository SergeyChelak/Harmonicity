//
//  WeakRef.swift
//  Harmonicity
//
//  Created by Sergey on 05.06.2025.
//

import Foundation

class WeakRef<T> {
    private weak var _value: AnyObject?
    
    init(value: T) {
        self._value = value as AnyObject
    }
    
    var value: T? {
        _value as? T
    }
}
