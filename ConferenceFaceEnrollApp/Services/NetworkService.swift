//
//  NetworkService.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//
//  This file defines the `NetworkService` class, which provides networking functionality for the app.
//  It uses Alamofire to handle HTTP requests and responses.
//
//  Key Features:
//  - Singleton instance for centralized network operations.
//  - Provides methods for user sign-up with or without photo upload.
//

import Foundation
import Alamofire

// MARK: - NetworkService

/**
 * The `NetworkService` class handles API calls for the app.
 *
 * - Methods:
 *   - `signUp(username:completion:)`: Sends a sign-up request with the username.
 *   - `signUpWithPhoto(username:photoData:completion:)`: Sends a sign-up request with the username and photo data.
 *
 * This class uses Alamofire for making HTTP requests and decoding responses.
 */

final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    /**
     * The `signUp` method sends a simple sign-up request with the username.
     *
     * - Parameters:
     *   - username: The username to sign up.
     *   - completion: A closure to handle the result of the API call.
     */

    // Simple sign-up API call example, parameters as dictionary
    func signUp(username: String, completion: @escaping (Result<SimpleResponse, AFError>) -> Void) {
        let params: [String: Any] = [
            "username": username,
            "note": "Test signup without image upload"
        ]

        AF.request("https://jsonplaceholder.typicode.com/posts",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default)
          .validate()
          .responseDecodable(of: SimpleResponse.self) { response in
              completion(response.result)
          }
    }

    /**
     * The `signUpWithPhoto` method sends a sign-up request with the username and photo data.
     *
     * - Parameters:
     *   - username: The username to sign up.
     *   - photoData: The photo data to upload.
     *   - completion: A closure to handle the result of the API call.
     */

    // Upload photo + username example, you can extend this
    func signUpWithPhoto(username: String, photoData: Data, completion: @escaping (Result<APIResponse, AFError>) -> Void) {
        let fileName = UUID().uuidString + ".jpg"

        AF.upload(multipartFormData: { form in
            form.append(photoData, withName: "photo", fileName: fileName, mimeType: "image/jpeg")
            form.append(Data(username.utf8), withName: "username")
        }, to: "https://your.api.endpoint/register-face")
        .validate()
        .responseDecodable(of: APIResponse.self) { response in
            completion(response.result)
        }
    }
    
    
    //    func signUp() {
    //        isLoading = true
    //
    //        let fileName = UUID().uuidString + ".jpg"
    //        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
    //        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
    //        try? data.write(to: path)
    //
    //        let newUser = EnrolledUser(username: username, imagePath: path.path)
    //        modelContext.insert(newUser)
    //
    //        AF.upload(multipartFormData: { form in
    //            form.append(data, withName: "photo", fileName: fileName, mimeType: "image/jpeg")
    //            form.append(Data(username.utf8), withName: "username")
    //        }, to: "https://your.api.endpoint/register-face")
    //        .responseDecodable(of: APIResponse.self) { response in
    //            DispatchQueue.main.async {
    //                isLoading = false
    //                switch response.result {
    //                case .success(let api):
    //                    if api.status, let faceID = api.face_id {
    //                        newUser.faceID = faceID
    //                        newUser.status = .uploaded
    //                        toastMessage = "Signed up with Face ID: \(faceID.prefix(8))"
    //                    } else {
    //                        newUser.status = .failed
    //                        toastMessage = api.message
    //                    }
    //                    try? modelContext.save()
    //                case .failure(let error):
    //                    newUser.status = .failed
    //                    toastMessage = error.localizedDescription
    //                }
    //                showToast = true
    //            }
    //        }
    //    }
}
