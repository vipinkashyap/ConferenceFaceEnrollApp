//
//  PreviewView.swift
//  ConferenceFaceEnrollApp
//
//  Created by Vipin Kumar Kashyap on 7/1/25.
//


import Alamofire
import SwiftUICore
import UIKit
import SwiftUI

// MARK: - Preview View

struct PreviewView: View {
    let image: UIImage
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var username: String = ""
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var didSignUp = false
    @State private var showStats = false


    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)

                TextField("Enter your name", text: $username)
                    .font(.title2)
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .frame(height: 50)

                HStack(spacing: 40) {
                    Button("Retake") {
                        hideKeyboard()
                        dismiss()
                    }
                    .disabled(isLoading || didSignUp)
                    .foregroundColor(.white)
                    .padding()
                    .background(isLoading || didSignUp ? Color.gray : Color.red)
                    .cornerRadius(8)

                    Button("Sign Up") {
                        hideKeyboard()
                        signUp()
                    }
                    .disabled(username.isEmpty || isLoading || didSignUp)
                    .foregroundColor(.white)
                    .padding()
                    .background(username.isEmpty || isLoading || didSignUp ? Color.gray : Color.blue)
                    .cornerRadius(8)
                }

                if didSignUp {
                    Button("Sign Up New User") {
                        username = ""
                        didSignUp = false
                        dismiss()
                    }
                    .padding(.all, 15)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                }

                if isLoading {
                    ProgressView("Signing you up...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
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
            .onTapGesture(count: 3) {
                showStats = true
            }
            .sheet(isPresented: $showStats) {
                SecretStatsView()
            }
        }
    }



    func signUp() {
        isLoading = true

        let newUser = EnrolledUser(username: username, imagePath: "local-path-placeholder")
        modelContext.insert(newUser)

        NetworkService.shared.signUp(username: username) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    newUser.faceID = "test-face-id-1234"
                    newUser.status = .uploaded
                    toastMessage = "Signed up! Response ID: \(response.id)"
                    didSignUp = true
                case .failure(let error):
                    newUser.status = .failed
                    toastMessage = "Failed: \(error.localizedDescription)"
                }
                try? modelContext.save()
                showToast = true
            }
        }
    }
}



extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
