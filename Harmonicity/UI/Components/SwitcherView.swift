//
//  SwitcherView.swift
//  Harmonicity
//
//  Created by Sergey on 04.06.2025.
//

import SwiftUI

enum SwitcherContent {
    case text(String)
    case image(String)
}

typealias SwitcherHandler = (Int) -> Void

struct SwitcherView: View {
    @ObservedObject private var viewModel: SwitcherViewModel
    
    init(
        items: [SwitcherContent],
        selected: Int = 0,
        handler: @escaping SwitcherHandler
    ) {
        viewModel = SwitcherViewModel(
            items: items,
            selected: selected,
            handler: handler
        )
    }
        
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
                .foregroundStyle(.blue)
                .padding(2)
        }
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


class SwitcherViewModel: ObservableObject {
    private(set) var items: [SwitcherContent]
    private let handler: SwitcherHandler
    @Published private(set) var current: Int {
        didSet {
            handler(current)
        }
    }
    
    init(
        items: [SwitcherContent],
        selected: Int,
        handler: @escaping SwitcherHandler
    ) {
        assert(!items.isEmpty)
        self.items = items
        self.current = selected
        self.handler = handler
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

#Preview {
    SwitcherView(items: [
        .text("Large Hall"),
        .text("Cathedral"),
        .text("Small Room")
    ]) { _ in }
}
