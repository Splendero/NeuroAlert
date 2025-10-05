//
//  ContentView.swift
//  NeuroAlert
//
//  Created by Spencer Osborn on 2025-10-05.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BrainWaveViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Text("🧠 Brain Waves")
                .font(.title2)
                .fontWeight(.bold)

            if let waves = viewModel.brainWaves {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Delta: \(waves.delta)")
                    Text("Theta: \(waves.theta)")
                    Text("Alpha: \(waves.alpha)")
                    Text("Beta: \(waves.beta)")
                    Text("Gamma: \(waves.gamma)")
                }
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .transition(.opacity)
            } else {
                ProgressView("Waiting for data...")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

