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
            } withCancel: { error in
                print("❌ Firebase error:", error.localizedDescription)
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
            // ✅ Handle timestamp separately before JSON decoding
            var mutableValue = value
            
            // Convert timestamp string to Date if it exists
            if let timestampString = value["timestamp"] as? String {
                if let date = ISO8601DateFormatter().date(from: timestampString) {
                    mutableValue["timestamp"] = date.timeIntervalSince1970 // Convert to timestamp
                } else {
                    mutableValue["timestamp"] = Date().timeIntervalSince1970
                }
            }
            
            let data = try JSONSerialization.data(withJSONObject: mutableValue)
            let decoded = try JSONDecoder().decode(BrainWaves.self, from: data)
            return decoded
        } catch {
            print("❌ Error decoding brain waves:", error)
            return nil
        }
    }

    private func enqueue(_ newWave: BrainWaves) {
        DispatchQueue.main.async {
            self.recentWaves.append(newWave)
            if self.recentWaves.count > self.maxStored {
                self.recentWaves.removeFirst(self.recentWaves.count - self.maxStored)
            }
        }
    }
}


