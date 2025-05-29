//
//  KeyboardView+KeyView.swift
//  Harmonicity
//
//  Created by Sergey on 28.05.2025.
//

import SwiftUI

extension KeyboardView {
    typealias KeyActionCallback = (MidiNote, Bool) -> Void
    
    fileprivate enum SharedConstants {
        static let width: CGFloat = 50.0
    }
    
    struct KeyView: View {
        @GestureState private var isPressed = false
        @State private var isTouching = false
        
        let note: Note
        let octave: Int
        let callback: KeyActionCallback
        
        var body: some View {
            Rectangle()
                .foregroundStyle(color)
                .frame(
                    width: SharedConstants.width,
                    height: height
                )
                .contentShape(Rectangle())
                .gesture(
                    // issue appears on long touch: on ended never called
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard !isTouching else {
                                return
                            }
                            onPress(true)
                        }
                        .onEnded { _ in
                            onPress(false)
                        }
                )
        }
        
        private func onPress(_ isPressed: Bool) {
            print("Virtual keyboard: \(note)\(octave) is pressed \(isPressed)")
            let note = MidiNote(
                note: MidiNoteNumber(note.rawValue + 12 * (1 + octave)),
                velocity: isPressed ? 62 : 0
            )
            callback(note, isPressed)
            isTouching = isPressed
        }
        
        private var height: CGFloat {
            Note.natural.contains(note) ? 150 : 70
        }
        
        private var color: Color {
            if isTouching {
                return .orange
            }
            if Note.natural.contains(note) {
                return .white
            }
            return .black
        }
    }
    
    struct DummyKeyView: View {
        var body: some View {
            Rectangle()
                .foregroundStyle(.clear)
                .frame(
                    width: SharedConstants.width,
                    height: 1
                )
        }
    }
}

#Preview {
    ZStack(alignment: .top) {
        KeyboardView.KeyView(note: .c, octave: 1) { _, _ in }
        KeyboardView.KeyView(note: .cs, octave: 1) { _, _ in }
    }
}
