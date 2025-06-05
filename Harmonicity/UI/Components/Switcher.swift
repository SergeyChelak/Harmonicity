//
//  Switcher.swift
//  Harmonicity
//
//  Created by Sergey on 04.06.2025.
//

import SwiftUI

enum SwitcherContent {
    case text(String)
    case image(String)
}

struct Switcher: View {
    @ObservedObject var viewModel: SwitcherViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            button(
                imageName: "left-arrow",
                action: viewModel.prev
            )
                        
            SwitcherContentView(
                item: viewModel.selectedItem
            )
            .frame(width: 120)
            
            button(
                imageName: "right-arrow",
                action: viewModel.next
            )
        }
    }
    
    private func button(
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(imageName)
                .renderingMode(.template)
                .foregroundStyle(.green)
        }
    }
}


class SwitcherViewModel: ObservableObject {
    private(set) var items: [SwitcherContent]
    @Published private(set) var current: Int
    
    init(items: [SwitcherContent]) {
        assert(!items.isEmpty)
        self.items = items
        self.current = 0
    }
    
    var selectedItem: SwitcherContent {
        items[current]
    }
    
    func prev() {
        let count = items.count
        current = (current + count - 1) % count
    }
    
    func next() {
        let count = items.count
        current = (current + 1) % count
    }
}


struct SwitcherContentView: View {
    let item: SwitcherContent
    
    var body: some View {
        switch item {
        case .text(let string):
            Text(string)
                .font(.title)
                .foregroundStyle(.red)
        case .image(let string):
            Image(string)
        }
    }
}

#Preview {
    let viewModel = SwitcherViewModel(items: [
        .text("Large Hall"),
        .text("Cathedral"),
        .text("Small Room")
    ])
    return Switcher(viewModel: viewModel)
}
