//
//  NetworkService.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//


import Foundation
import Alamofire

final class NetworkService {
    static let shared = NetworkService()

    private init() {}

    // Simple sign-up API call example, parameters as dictionary
    func signUp(username: String, completion: @escaping (Result<SimpleResponse, AFError>) -> Void) {
        let params: [String: Any] = [
            "username": username,
            "note": "Test signup without image upload"
        ]

        AF.request("https://jsonplaceholder.typicode.com/psts",
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default)
          .validate()
          .responseDecodable(of: SimpleResponse.self) { response in
              completion(response.result)
          }
    }

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
