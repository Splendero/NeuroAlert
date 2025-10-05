//
//  DataBase.swift
//  NeuroAlert
//
//  Created by Spencer Osborn on 2025-10-05.
//
import Foundation
import FirebaseDatabase
import Combine

class BrainWaveViewModel: ObservableObject {
    @Published var brainWaves: BrainWaves?

    private var ref = Database.database().reference()

    init() {
        observeLatestBrainWaves()
    }

    func observeLatestBrainWaves() {
        // Listen under "eeg", get the most recent entry
        ref.child("eeg").queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            // inside each child (auto-id), get "computer"
            let computerRef = snapshot.childSnapshot(forPath: "computer")

            guard let value = computerRef.value as? [String: Any] else {
                print("⚠️ Could not parse computer node")
                return
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: value)
                let decoded = try JSONDecoder().decode(BrainWaves.self, from: data)
                DispatchQueue.main.async {
                    self.brainWaves = decoded
                }
                print("✅ Received data:", decoded)
            } catch {
                print("❌ Error decoding brain waves:", error)
            }
        }
    }
}


