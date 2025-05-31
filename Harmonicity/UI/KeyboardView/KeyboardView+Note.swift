//
//  KeyboardView+Note.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import Foundation

extension KeyboardView {
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
    }
}
