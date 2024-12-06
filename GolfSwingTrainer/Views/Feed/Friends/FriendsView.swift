//
//  FriendsView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var friendUsername: String = ""
    @State private var isLoading: Bool = false
    @State private var feedbackMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if let account = userDataViewModel.user?.firestoreAccount {
                    VStack {
                        AddFriendsComponentView(
                            friendUsername: $friendUsername,
                            isLoading: $isLoading,
                            feedbackMessage: $feedbackMessage
                        )
                        FriendsListsComponentView(account: account, feedbackMessage: $feedbackMessage)
                            .environmentObject(userDataViewModel)
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
        .onAppear {
            Task {
                await userDataViewModel.loadUser()
            }
        }
    }
}
#Preview {
    FriendsView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
