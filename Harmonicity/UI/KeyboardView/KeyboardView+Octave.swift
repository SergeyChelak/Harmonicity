//
//  OctaveKeyboardView.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import SwiftUI

extension KeyboardView {
    struct OctaveKeyboardView: View {
        private let whiteRow: [AnyView]
        private let blackRow: [AnyView]
        
        init(octave: Int, callback: @escaping KeyActionCallback) {
            var views: [AnyView] = []
            for note in Note.allCases {
                let view = KeyView(
                    note: note,
                    octave: octave,
                    callback: callback
                )
                views.append(AnyView(view))
            }
            let whiteRow = Note.natural.map { views[$0.rawValue] }
            self.whiteRow = whiteRow
            
            var blackRow = Note.alterated.map { views[$0.rawValue] }
            blackRow.insert(AnyView(DummyKeyView()), at: 2)
            self.blackRow = blackRow
        }
        
        var body: some View {
            ZStack(alignment: .top) {
                keysRow(whiteRow)
                keysRow(blackRow)
            }
        }
        
        func keysRow(_ viewRow: [AnyView]) -> some View {
            HStack(spacing: 4) {
                ForEach(viewRow.indices, id: \.self) { idx in
                    viewRow[idx]
                }
            }
            
        }
    }
}

#Preview {
    KeyboardView.OctaveKeyboardView(octave: 1) { _, _ in }
}
