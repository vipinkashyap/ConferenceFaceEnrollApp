import SwiftUI
import SwiftData

struct SecretStatsView: View {
    @Query private var enrolledUsers: [EnrolledUser]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedUser: EnrolledUser?

    var body: some View {
        NavigationView {
            List {
                if enrolledUsers.isEmpty {
                    Text("No enrolled users yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(enrolledUsers, id: \.id) { user in
                        HStack(spacing: 12) {
                            if let image = loadImage(from: user.imagePath) {
                                Button {
                                    selectedUser = user
                                } label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "person.crop.circle.badge.exclam")
                                            .foregroundColor(.white)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.headline)
                                Text("Status: \(user.status.rawValue.capitalized)")
                                    .font(.subheadline)
                                Text("Created: \(user.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Enrolled Users")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedUser) { user in
                UserPreviewSheet(user: user)
            }
        }
    }
    
    // MARK: Load Image
    private func loadImage(from filename: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(filename)

        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("📂 Loading from: \(fileURL.path) | Exists: \(fileExists)")

        return UIImage(contentsOfFile: fileURL.path)
    }
}
