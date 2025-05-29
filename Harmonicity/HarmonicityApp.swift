//
//  HarmonicityApp.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

@main
struct HarmonicityApp: App {
    enum HarmonicityAppState {
        case initial
        case ready(Context)
        case error(Error)
    }

    @State
    private var state: HarmonicityAppState = .initial
    
    var body: some Scene {
        WindowGroup {
            contentView()
                .task {
                    do {
                        let context = try composeContext()
                        state = .ready(context)
                    } catch {
                        state = .error(NSError(domain: "HarmonicityApp", code: -1))
                    }
                }
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch state {
        case .initial:
            Text("Loading...")
        case .ready(let context):
            ContentView(context: context)
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}
