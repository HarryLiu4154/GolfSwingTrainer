//
//  SettingsAccountView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-30.
//

import SwiftUI

struct SettingsAccountView: View {
    @EnvironmentObject var viewModel: UserDataViewModel
    @State private var isEditing = false
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var playerLevel = ""
    @State private var playerStatus = ""

    // Account Levels and Statuses
    let playerLevels = ["Beginner", "Intermediate", "Amateur", "Expert"]
    let playerStatuses = ["Just for fun", "Trainer", "Competitor/Professional"]

    var body: some View {
        NavigationStack {
            VStack {
                if let account = viewModel.user?.firestoreAccount {
                    Form {
                        // Display Account Data Section
                        Section(header: Text("Account Information")) {
                            accountDisplaySection(account: account)
                        }

                        if isEditing {
                            // Edit Account Data Section
                            Section(header: Text("Edit Your Information")) {
                                accountEditSection()
                            }
                        }
                    }

                    // Action Buttons
                    if isEditing {
                        HStack {
                            Button("Save Changes") {
                                Task {
                                    await saveChanges(account: account)
                                    isEditing = false
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Cancel") {
                                isEditing = false
                                resetEditFields(account: account)
                            }
                            .foregroundColor(.red)
                        }
                        .padding()
                    } else {
                        HStack {
                            Button("Edit Account") {
                                isEditing = true
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Delete Account") {
                                Task {
                                    await viewModel.deleteAccount()
                                }
                            }
                            .foregroundColor(.red)
                        }
                        .padding()
                    }
                } else {
                    // No Account Found Section
                    VStack {
                        Text("No account found. Create one to unlock more features.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button("Create Account") {
                            Task {
                                await createNewAccount()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Account Settings")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                if let account = viewModel.user?.firestoreAccount {
                    resetEditFields(account: account)
                }
            }
        }
    }

    // MARK: - Subviews
    private func accountDisplaySection(account: Account) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Username:")
                Spacer()
                Text(account.userName).foregroundColor(.secondary)
            }

            HStack {
                Text("Profile Picture:")
                Spacer()
                if let profilePictureURL = account.profilePictureURL, selectedImage == nil {
                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle().fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                } else if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                        .overlay(Text(viewModel.user?.initials ?? ""))
                }
            }
        }
    }

    private func accountEditSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Profile Picture:")
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } else {
                        Text("Tap to Edit")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    showImagePicker = true
                }
            }

            Picker("Player Level", selection: $playerLevel) {
                ForEach(playerLevels, id: \.self) { level in
                    Text(level).tag(level)
                }
            }

            Picker("Player Status", selection: $playerStatus) {
                ForEach(playerStatuses, id: \.self) { status in
                    Text(status).tag(status)
                }
            }
        }
    }

    // MARK: - Helper Functions
    private func resetEditFields(account: Account) {
        selectedImage = nil
        playerLevel = account.playerLevel
        playerStatus = account.playerStatus
    }

    private func saveChanges(account: Account) async {
        do {
            try await viewModel.updateAccount(
                userName: account.userName, // Username cannot be changed
                profileImage: selectedImage,
                playerLevel: playerLevel,
                playerStatus: playerStatus
            )
        } catch {
            print("Failed to save changes: \(error.localizedDescription)")
        }
    }

    private func createNewAccount() async {
        do {
            guard let user = viewModel.user else { return }
            let newAccount = Account(
                id: UUID(),
                ownerUid: user.uid,
                userName: user.fullName.replacingOccurrences(of: " ", with: "").lowercased(),
                profilePictureURL: nil,
                playerLevel: "Beginner",
                playerStatus: "Just for fun",
                friends: [],
                friendRequests: FriendRequests(incoming: [], outgoing: [])
            )
            try await viewModel.firebaseService.saveAccount(newAccount, forUser: user.uid)
            viewModel.user?.firestoreAccount = newAccount
        } catch {
            print("Failed to create new account: \(error.localizedDescription)")
        }
    }
}




#Preview {
    SettingsAccountView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
