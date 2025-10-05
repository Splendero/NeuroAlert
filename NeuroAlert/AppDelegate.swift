//
//  AppDelegate.swift
//  NeuroAlert
//
//  Created by Spencer Osborn on 2025-10-05.
//


import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("✅ Firebase configured")
        return true
    }
}
