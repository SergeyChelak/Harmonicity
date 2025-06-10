//
//  Range+Utils.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

typealias CoreRange = Range<CoreFloat>

extension CoreRange {
    var length: CoreFloat {
        upperBound - lowerBound
    }
}
