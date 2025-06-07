//
//  GroupViewModifier.swift
//  Harmonicity
//
//  Created by Sergey on 07.06.2025.
//

import SwiftUI

struct GroupViewModifier: ViewModifier {
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat
    private let padding: CGFloat
    
    init(
        cornerRadius: CGFloat,
        lineWidth: CGFloat,
        padding: CGFloat
    ) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                Color.brown
                    .cornerRadius(cornerRadius)
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(.yellow)
            }
    }
}

extension View {
    func groupStyle(
        cornerRadius: CGFloat = 8,
        lineWidth: CGFloat = 4,
        padding: CGFloat = 10
    ) -> some View {
        let modifier = GroupViewModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            padding: padding
        )
        return self.modifier(modifier)
    }
}
