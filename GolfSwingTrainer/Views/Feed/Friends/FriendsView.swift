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
    @State private var feedbackMessage: String? // Feedback message for friend request actions

    /*Had to break this section into modular components to give the compiler a break*/
    var body: some View {
        NavigationStack {
            if let account = userDataViewModel.user?.firestoreAccount {
                VStack {
                    AddFriendsComponentView(
                        friendUsername: $friendUsername,
                        isLoading: $isLoading,
                        feedbackMessage: $feedbackMessage
                    )

                    FriendsListsComponentView(account: account, feedbackMessage: $feedbackMessage)
                }
                .navigationTitle("Friends")
                .refreshable {
                    await userDataViewModel.loadUser()
                }
                .overlay(
                    LoadingOverlay(isLoading: isLoading, message: "Loading....")
                )
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
