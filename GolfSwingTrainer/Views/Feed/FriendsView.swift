//
//  FriendsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var friendUsername: String = "" // Input field for adding friends
    @State private var isLoading: Bool = false // Loading indicator

    var body: some View {
        NavigationStack {
            if let account = userDataViewModel.user?.account {
                VStack {
                    // Add Friend Section
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
                                        await userDataViewModel.loadUser()
                                    } catch {
                                        print("Error adding friend: \(error.localizedDescription)")
                                    }
                                    friendUsername = ""
                                    isLoading = false
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(friendUsername.isEmpty || isLoading)
                        }
                    }
                    .padding()
                    
                    .navigationTitle("Friends")
                    .refreshable {
                        await userDataViewModel.loadUser()
                    }
                }
            } else {
                Text("You need an account to manage friends.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
}
#Preview {
    FriendsView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
