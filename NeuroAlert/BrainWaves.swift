//
//  BrainWaves.swift
//  NeuroAlert
//
//  Created by Spencer Osborn on 2025-10-05.
//
import Foundation

struct BrainWaves: Codable, Identifiable {
    var id = UUID()
    var alpha: Double
    var beta: Double
    var delta: Double
    var gamma: Double
    var theta: Double
    var timestamp: Date

    enum CodingKeys: String, CodingKey {
        case alpha, beta, delta, gamma, theta, timestamp
    }
}

struct BrainWavesLast10: Codable {
    var brainWaves: [BrainWaves]
}
