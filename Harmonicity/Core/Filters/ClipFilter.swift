//
//  ClipFilter.swift
//  Harmonicity
//
//  Created by Sergey on 29.05.2025.
//

import Foundation

final class ClipFilter: CoreProcessor {
    private let minimum: Sample
    private let maximum: Sample
    
    init(minimum: Sample, maximum: Sample) {
        self.minimum = minimum
        self.maximum = maximum
    }
    
    func process(_ sample: Sample) -> Sample {
        max(min(sample, maximum), minimum)
    }
}
