//
//  ContentView.swift
//  NeuroAlert
//
//  Created by Spencer Osborn on 2025-10-05.
//

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

            if let waves = viewModel.latest {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Delta: \(waves.delta, specifier: "%.2f")")
                    Text("Theta: \(waves.theta, specifier: "%.2f")")
                    Text("Alpha: \(waves.alpha, specifier: "%.2f")")
                    Text("Beta: \(waves.beta, specifier: "%.2f")")
                    Text("Gamma: \(waves.gamma, specifier: "%.2f")")
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

