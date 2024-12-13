//
//  AddFriendsComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct AddFriendsComponentView: View {
    @Binding var friendUsername: String
    @Binding var isLoading: Bool
    @Binding var feedbackMessage: String?
    @EnvironmentObject var userDataViewModel: UserDataViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Add a Friend")
                .font(.headline)

            HStack {
                TextField("Enter username", text: $friendUsername)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    Task {
                        isLoading = true
                        do {
                            await userDataViewModel.sendFriendRequest(to: friendUsername)
                            feedbackMessage = "Friend request sent to \(friendUsername)"
                            await userDataViewModel.loadUser() // Refresh user data
                        } catch {
                            feedbackMessage = "Error sending friend request: \(error.localizedDescription)"
                        }
                        friendUsername = ""
                        isLoading = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(friendUsername.isEmpty || isLoading)
            }
            if let feedbackMessage = feedbackMessage {
                Text(feedbackMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    AddFriendsComponentView(friendUsername: .constant("Name"), isLoading: .constant(true), feedbackMessage: .constant("Message"))
}
