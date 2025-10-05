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
    @Published var latest: BrainWaves?
    @Published var recentWaves: [BrainWaves] = []

    private var ref = Database.database().reference()
    private let maxStored = 120

    init() {
        observeLatestBrainWaves()
    }

    func observeLatestBrainWaves() {
        // Fetch last 200 readings initially
        ref.child("eeg")
            .queryLimited(toLast: 200)
            .observeSingleEvent(of: .value) { snapshot in
                var temp: [BrainWaves] = []

                for child in snapshot.children {
                    guard let snap = child as? DataSnapshot else { continue }
                    let computerRef = snap.childSnapshot(forPath: "computer")
                    guard let value = computerRef.value as? [String: Any] else { continue }

                    if let wave = self.decodeWave(from: value) {
                        temp.append(wave)
                    }
                }

                DispatchQueue.main.async {
                    self.recentWaves = temp.sorted { $0.timestamp < $1.timestamp }
                    self.latest = self.recentWaves.last
                }

                // After initial load, start listening for new data
                self.listenForNewWaves()
            }
    }

    private func listenForNewWaves() {
        ref.child("eeg").queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            let computerRef = snapshot.childSnapshot(forPath: "computer")
            guard let value = computerRef.value as? [String: Any] else {
                print("⚠️ Could not parse computer node")
                return
            }

            if let wave = self.decodeWave(from: value) {
                DispatchQueue.main.async {
                    self.latest = wave
                    self.enqueue(wave)
                }
            }
        }
    }

    private func decodeWave(from value: [String: Any]) -> BrainWaves? {
        do {
            let data = try JSONSerialization.data(withJSONObject: value)
            var decoded = try JSONDecoder().decode(BrainWaves.self, from: data)
            if let ts = value["timestamp"] as? String,
               let date = ISO8601DateFormatter().date(from: ts) {
                decoded.timestamp = date
            } else {
                decoded.timestamp = Date()
            }
            return decoded
        } catch {
            print("❌ Error decoding brain waves:", error)
            return nil
        }
    }

    private func enqueue(_ newWave: BrainWaves) {
        recentWaves.append(newWave)
        if recentWaves.count > maxStored {
            recentWaves.removeFirst(recentWaves.count - maxStored)
        }
    }
}


