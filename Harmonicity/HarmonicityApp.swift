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

#if os(OSX)
    init() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // escape
            if event.keyCode == 53 {
                Darwin.exit(0)
            }
            return event
        }
    }
#endif
    
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
            SynthesizerView(context: context)
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}
