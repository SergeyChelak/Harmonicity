//
//  Note.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

enum Note: Int, CaseIterable {
    case c
    case cs
    case d
    case ds
    case e
    case f
    case fs
    case g
    case gs
    case a
    case `as`
    case b
    
    static let natural: [Note] = [.c, .d, .e, .f, .g, .a, .b]
    static let alterated: [Note] = [.cs, .ds, .fs, .gs, .as]
    
    var frequency: Float {
        switch self {
        case .c:
            32.7032
        case .cs:
            34.6478
        case .d:
            36.7081
        case .ds:
            38.8909
        case .e:
            41.2034
        case .f:
            43.6535
        case .fs:
            46.2493
        case .g:
            48.9994
        case .gs:
            51.9131
        case .a:
            55.0000
        case .as:
            58.2705
        case .b:
            61.7354
        }
    }
}
