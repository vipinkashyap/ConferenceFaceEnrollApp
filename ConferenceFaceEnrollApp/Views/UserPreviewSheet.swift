import SwiftUI
import UIKit

struct UserPreviewSheet: View {
    let user: EnrolledUser

    private func loadImage(from filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 40)

            if let image = loadImage(from: user.imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 180, height: 180)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 8)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .overlay(
                        Image(systemName: "person.crop.circle.fill.badge.exclam")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .padding(40)
                    )
            }

            VStack(spacing: 8) {
                Text(user.username)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Status: \(user.status.rawValue.capitalized)")
                    .font(.headline)
                    .foregroundColor(user.status == .uploaded ? .green : .orange)

                Text("Created: \(user.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color(.systemBackground)
                .ignoresSafeArea()
        )
    }
}
