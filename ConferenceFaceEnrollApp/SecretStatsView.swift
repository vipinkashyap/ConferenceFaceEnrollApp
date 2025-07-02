import SwiftUI
import SwiftData

struct SecretStatsView: View {
    // Query all EnrolledUser entities
    @Query private var enrolledUsers: [EnrolledUser]

    // Environment dismiss to close the sheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                if enrolledUsers.isEmpty {
                    Text("No enrolled users yet.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(enrolledUsers, id: \.id) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.username)
                                .font(.headline)
                            Text("Status: \(user.status.rawValue.capitalized)")
                                .font(.subheadline)
                            Text("Created: \(user.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
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
        }
    }
}