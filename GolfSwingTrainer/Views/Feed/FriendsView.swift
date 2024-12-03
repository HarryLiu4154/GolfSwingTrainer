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
    var body: some View {
        NavigationStack {
            if let account = userDataViewModel.user?.account {
                // Add Friend Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add a Friend")
                        .font(.headline)
                    
                    HStack {
                        TextField("Enter username", text: $friendUsername)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Add") {
                            Task {
                                await userDataViewModel.addFriend(by: friendUsername)
                                await userDataViewModel.loadUser()
                                friendUsername = ""
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                VStack {
                    Form{
                        List {
                            // Friend Requests Section
                            if !account.friendRequests.isEmpty {
                                Section(header: Text("Friend Requests")) {
                                    ForEach(account.friendRequests, id: \.self) { requestId in
                                        HStack {
                                            Text(requestId) // Replace with username lookup if needed
                                            Spacer()
                                            Button("Accept") {
                                                Task {
                                                    await userDataViewModel.acceptFriendRequest(from: requestId)
                                                    await userDataViewModel.loadUser()
                                                }
                                            }
                                            .buttonStyle(.borderedProminent)
                                            Button("Decline") {
                                                Task {
                                                    await userDataViewModel.declineFriendRequest(from: requestId)
                                                    await userDataViewModel.loadUser()
                                                }
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                }
                            }
                            
                            // Friends Section
                            if !account.friends.isEmpty {
                                Section(header: Text("Friends")) {
                                    ForEach(account.friends, id: \.self) { friendId in
                                        HStack {
                                            Text(friendId) // Replace with username lookup if needed
                                            Spacer()
                                            Button("Remove") {
                                                Task {
                                                    await userDataViewModel.removeFriend(friendId: friendId)
                                                    await userDataViewModel.loadUser()
                                                }
                                            }
                                            .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                        
                        
                        
                        
                    }
                    .navigationTitle("Friends")
                    .refreshable {
                        await userDataViewModel.loadUser()
                    }
                } else {
                    Text("You need an account to manage friends.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
    }
}

#Preview {
    FriendsView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
