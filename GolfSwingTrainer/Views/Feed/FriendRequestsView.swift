//
//  FriendRequestsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct FriendRequestsView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var feedbackMessage: String? // Feedback for user actions

    var body: some View {
        NavigationStack {
            if let incomingRequests = userDataViewModel.user?.firestoreAccount?.friendRequests.incoming, !incomingRequests.isEmpty {
                List {
                    Section(header: Text("Incoming Friend Requests")) {
                        ForEach(incomingRequests, id: \.self) { request in
                            HStack {
                                Text(request)
                                Spacer()
                                Button("Accept") {
                                    Task {
                                        do {
                                            await userDataViewModel.acceptFriendRequest(from: request)
                                            feedbackMessage = "Accepted friend request from \(request)"
                                            await userDataViewModel.loadUser()
                                        } catch {
                                            feedbackMessage = "Failed to accept request: \(error.localizedDescription)"
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)

                                Button("Decline") {
                                    Task {
                                        do {
                                            await userDataViewModel.declineFriendRequest(from: request)
                                            feedbackMessage = "Declined friend request from \(request)"
                                            await userDataViewModel.loadUser()
                                        } catch {
                                            feedbackMessage = "Failed to decline request: \(error.localizedDescription)"
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .navigationTitle("Friend Requests")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            // Dismiss the view
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            } else {
                VStack {
                    Text("No incoming friend requests.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                .navigationTitle("Friend Requests")
            }
        }
    }
}

#Preview {
    FriendRequestsView()
}
