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

    /*Needed to break UI into modular components for compiler*/
    var body: some View {
        NavigationStack {
            VStack {
                if let account = viewModel.user?.firestoreAccount {
                    // Display/Edit Form
                    AccountFormComponentView(
                        account: account,
                        isEditing: isEditing,
                        selectedImage: $selectedImage,
                        playerLevel: $playerLevel,
                        playerStatus: $playerStatus,
                        showImagePicker: $showImagePicker
                    )
                    .onAppear {
                        resetEditFields(account: account)
                    }

                    // Action Buttons
                    AccountActionButtonsView(
                        isEditing: isEditing,
                        onEdit: { isEditing = true },
                        onCancel: {
                            isEditing = false
                            resetEditFields(account: account)
                        },
                        onSave: {
                            Task {
                                await saveChanges(account: account)
                                isEditing = false
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteAccount()
                            }
                        }
                    )
                } else {
                    // No Account Found Section
                    NoAccountComponentView(onCreate: {
                        Task {
                            await createNewAccount()
                        }
                    })
                }
            }
            .navigationTitle("Account Settings")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
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
