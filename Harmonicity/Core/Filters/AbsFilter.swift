//
//  AbsFilter.swift
//  Harmonicity
//
//  Created by Sergey on 30.05.2025.
//

import Foundation

final class AbsFilter: CoreProcessor {
    func process(_ sample: Sample) -> Sample {
        abs(sample)
    }
}
