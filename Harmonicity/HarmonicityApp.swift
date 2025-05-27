//
//  HarmonicityApp.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import SwiftUI

@main
struct HarmonicityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(OSX)
            .onDisappear {
                NSApplication.shared.terminate(nil)
            }
#endif
        }
    }
}
