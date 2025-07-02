//
//  ConferenceFaceEnrollAppApp.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
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
