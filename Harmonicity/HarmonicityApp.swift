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
        case ready(Synthesizer)
        case error(Error)
    }

    @State
    private var state: HarmonicityAppState = .initial
    
    var body: some Scene {
        WindowGroup {
            contentView()
                .task {
                    do {
                        let synth = Synthesizer()
                        try synth.setup()
                        state = .ready(synth)
                    } catch {
                        state = .error(NSError(domain: "HarmonicityApp", code: -1))
                        return
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
        case .ready(let synthesizer):
            ContentView(synth: synthesizer)
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}
