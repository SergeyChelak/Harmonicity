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
    private let title: String
    private let height: CGFloat
    
    init(
        title: String,
        height: CGFloat,
        cornerRadius: CGFloat,
        lineWidth: CGFloat,
        padding: CGFloat
    ) {
        self.title = title
        self.height = height
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.padding = padding
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            HStack {
                VStack {
                    Text(title)
                        .font(.title)
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(height: height)
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
        title: String,
        height: CGFloat,
        cornerRadius: CGFloat = 8,
        lineWidth: CGFloat = 4,
        padding: CGFloat = 10
    ) -> some View {
        let modifier = GroupViewModifier(
            title: title,
            height: height,
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            padding: padding
        )
        return self.modifier(modifier)
    }
}
