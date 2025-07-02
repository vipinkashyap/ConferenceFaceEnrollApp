//
// ConferenceFaceEnrollApp.swift
// App Entry Point

import SwiftUI
import SwiftData
import AVFoundation
import Alamofire
import Vision

// MARK: - SwiftData Model

@Model
final class EnrolledUser {
    var id: UUID
    var username: String
    var imagePath: String
    var faceID: String?
    var status: UploadStatus
    var createdAt: Date

    init(username: String, imagePath: String, faceID: String? = nil, status: UploadStatus = .pending) {
        self.id = UUID()
        self.username = username
        self.imagePath = imagePath
        self.faceID = faceID
        self.status = status
        self.createdAt = Date()
    }
}



// MARK: - App Entry

// @main
// struct ConferenceFaceEnrollApp: App {
//     var body: some Scene {
//         WindowGroup {
//             CameraView()
//         }
//         .modelContainer(for: EnrolledUser.self)
//     }
// }
