//
//  Range+Utils.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

extension Range<CoreFloat> {
    var length: CoreFloat {
        upperBound - lowerBound
    }
}
