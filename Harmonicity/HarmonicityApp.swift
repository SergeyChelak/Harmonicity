//
//  HarmonicityApp.swift
//  Harmonicity
//
//  Created by Sergey on 27.05.2025.
//

import Combine
import SwiftUI

final class HarmonicityAppContext {
    private var cancellable: AnyCancellable?
    let synth: Synthesizer
    let midiInput: MidiInputService
    
    init(synth: Synthesizer, midiInput: MidiInputService) {
        self.synth = synth
        self.midiInput = midiInput
        
        setup()
    }
    
    private func setup() {
        cancellable = midiInput.publisher
            .sink { [weak self] event in
                self?.synth.processMidiEvent(event)
            }
    }
}

@main
struct HarmonicityApp: App {
    enum HarmonicityAppState {
        case initial
        case ready(HarmonicityAppContext)
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
                        
                        let midiInput = MidiInputService()
                        
                        let context = HarmonicityAppContext(
                            synth: synth,
                            midiInput: midiInput
                        )
                        state = .ready(context)
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
        case .ready(let context):
            ContentView(context: context)
        case .error(let error):
            Text(error.localizedDescription)
        }
    }
}
