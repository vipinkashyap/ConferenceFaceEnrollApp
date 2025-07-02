//
//  ConferenceFaceEnrollAppApp.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//
//  This file defines the main entry point for the ConferenceFaceEnrollApp application.
//  It sets up the SwiftUI App structure and initializes the shared ModelContainer for managing data models.
//
//  The `@main` attribute marks the `ConferenceFaceEnrollAppApp` struct as the app's entry point.
//  The app uses a `NavigationView` to display the `CameraView` as the initial screen.
//
//  The `sharedModelContainer` is configured with a schema containing `Item` and `EnrolledUser` models.
//  It uses persistent storage unless an error occurs during initialization, in which case the app terminates.
//

import SwiftUI
import SwiftData

@main
struct ConferenceFaceEnrollAppApp: App {
    @State private var savedImagePath:String?
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            EnrolledUser.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                 CameraView(savedImagePath: $savedImagePath)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
