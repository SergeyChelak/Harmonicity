//
//  ClipFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class ClipFilter: CoreProcessor {
    private let minimum: CoreFloat
    private let maximum: CoreFloat
    
    init(minimum: CoreFloat, maximum: CoreFloat) {
        self.minimum = minimum
        self.maximum = maximum
    }
    
    func process(_ sample: CoreFloat) -> CoreFloat {
        max(min(sample, maximum), minimum)
    }
}
