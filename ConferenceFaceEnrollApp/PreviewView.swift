// MARK: - Preview View

struct PreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var username: String = ""
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 250, height: 250)

            TextField("Enter your name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack(spacing: 40) {
                Button("Retake") {
                    dismiss()
                }

                Button("Sign Up") {
                    signUp()
                }
                .disabled(username.isEmpty)
            }

            if isLoading {
                ProgressView("Signing you up...")
            }

            if showToast {
                Text(toastMessage)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    func signUp() {
        isLoading = true

        let fileName = UUID().uuidString + ".jpg"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: path)

        let newUser = EnrolledUser(username: username, imagePath: path.path)
        modelContext.insert(newUser)

        AF.upload(multipartFormData: { form in
            form.append(data, withName: "photo", fileName: fileName, mimeType: "image/jpeg")
            form.append(Data(username.utf8), withName: "username")
        }, to: "https://your.api.endpoint/register-face")
        .responseDecodable(of: APIResponse.self) { response in
            DispatchQueue.main.async {
                isLoading = false
                switch response.result {
                case .success(let api):
                    if api.status, let faceID = api.face_id {
                        newUser.faceID = faceID
                        newUser.status = .uploaded
                        toastMessage = "Signed up with Face ID: \(faceID.prefix(8))"
                    } else {
                        newUser.status = .failed
                        toastMessage = api.message
                    }
                    try? modelContext.save()
                case .failure(let error):
                    newUser.status = .failed
                    toastMessage = error.localizedDescription
                }
                showToast = true
            }
        }
    }

    struct APIResponse: Decodable {
        let status: Bool
        let message: String
        let face_id: String?
    }
}