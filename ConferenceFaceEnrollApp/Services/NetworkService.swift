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

        AF.request("https://jsonplaceholder.typicode.com/posts",
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
}