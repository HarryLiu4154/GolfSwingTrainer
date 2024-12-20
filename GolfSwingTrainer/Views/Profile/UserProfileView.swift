//
//  UserProfileView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @State private var showDeleteConfirmation = false // Controls the delete account pop-up confirmation
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            // Profile Image or Initials
                            ZStack {
                                if let profilePictureURL = user.firestoreAccount?.profilePictureURL, !profilePictureURL.isEmpty {
                                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 72, height: 72)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color(.systemGray3))
                                            .frame(width: 72, height: 72)
                                    }
                                } else {
                                    Circle()
                                        .fill(Color(.systemGray3))
                                        .frame(width: 72, height: 72)
                                        .overlay(
                                            Text(user.initials)
                                                .font(.title)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        )
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(user.firestoreAccount?.userName ?? "No username")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Section("General") {
                        HStack {
                            SettingRowComponentView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            Spacer()
                            Text("v1.0.0 - Alpha")
                                .foregroundStyle(.gray)
                        }
                    }

                    Section("Account") {
                        Button {
                            viewModel.signOut()
                            dismiss()
                        } label: {
                            SettingRowComponentView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: Color.yellow)
                        }

                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            SettingRowComponentView(imageName: "trash", title: "DELETE ACCOUNT", tintColor: Color.red)
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Are you sure?"),
                                message: Text("This action will permanently delete your account."),
                                primaryButton: .destructive(Text("Delete")) {
                                    Task {
                                        await viewModel.deleteAccount()
                                        dismiss()
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
                .refreshable {
                    Task {
                        await userDataViewModel.loadUser()
                    }
                }
                .onAppear {
                    Task {
                        await userDataViewModel.loadUser()
                    }
                }
                .navigationTitle("Your Profile")
            }
        }
    }
}

#Preview {
    
    UserProfileView().environmentObject(AuthViewModel(userDataViewModel: UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService())))
}
