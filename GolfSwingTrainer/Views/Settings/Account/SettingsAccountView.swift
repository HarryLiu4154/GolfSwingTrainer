//
//  SettingsAccountView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-30.
//

import SwiftUI

struct SettingsAccountView: View {
    @EnvironmentObject var viewModel: UserDataViewModel
    @State private var isEditing = false // Toggles editing mode
    
    // Temporary state variables for editing
    @State private var userName = ""
    @State private var selectedImage: UIImage? = nil // For updated profile picture
    @State private var showImagePicker = false
    @State private var playerLevel = ""
    @State private var playerStatus = ""
    
    // Account Levels and Statuses
    let playerLevels = ["Beginner", "Intermediate", "Amateur", "Expert"]
    let playerStatuses = ["Just for fun", "Trainer", "Competitor/Professional"]
    
    var body: some View {
        NavigationStack {
            Form {
                if let account = viewModel.user?.firestoreAccount {
                    // Account Data Section
                    Section(header: Text("Account Information")) {
                        if !isEditing {
                            // Display account data
                            accountDisplaySection(account: account)
                        } else {
                            // Edit account data
                            accountEditSection()
                        }
                    }
                } else {
                    // No account section
                    Section {
                        Text("No account found. Create one to unlock more features.")
                            .foregroundColor(.secondary)
                        Button("Create Account") {
                            Task {
                                await createNewAccount()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Actions Section
                Section {
                    if !isEditing {
                        if viewModel.user?.firestoreAccount != nil {
                            Button("Edit Account") {
                                startEditing()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Delete Account") {
                                Task {
                                    await viewModel.deleteAccount()
                                }
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        Button("Save Changes") {
                            Task {
                                await saveChanges()
                                stopEditing()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Cancel") {
                            stopEditing()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Your Account Information")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .task {
                // Load initial data for editing
                loadAccountData()
            }
        }
    }
    
    // MARK: - Subviews
    private func accountDisplaySection(account: Account) -> some View {
        Group {
            HStack {
                Text("Username")
                Spacer()
                Text(account.userName)
                    .foregroundColor(.secondary)
            }
            
            if let profilePictureURL = account.profilePictureURL {
                HStack {
                    Text("Profile Picture")
                    Spacer()
                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle().fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                HStack {
                    Text("Profile Picture")
                    Spacer()
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                        .overlay(Text(viewModel.user!.initials))
                }
            }
            
            HStack {
                Text("Player Level")
                Spacer()
                Text(account.playerLevel)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Player Status")
                Spacer()
                Text(account.playerStatus)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func accountEditSection() -> some View {
        Group {
            TextField("Username", text: $userName)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
            
            HStack {
                Text("Profile Picture")
                Spacer()
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "camera.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Picker("Player Level", selection: $playerLevel) {
                ForEach(playerLevels, id: \.self) { level in
                    Text(level)
                }
            }
            Picker("Player Status", selection: $playerStatus) {
                ForEach(playerStatuses, id: \.self) { status in
                    Text(status)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadAccountData() {
        if let account = viewModel.user?.firestoreAccount {
            // Load existing account data into state variables
            userName = account.userName
            playerLevel = account.playerLevel
            playerStatus = account.playerStatus
            selectedImage = nil // Reset the selected image for editing
        } else {
            // Default values for creating a new account
            userName = ""
            playerLevel = playerLevels.first ?? "Beginner"
            playerStatus = playerStatuses.first ?? "Just for fun"
            selectedImage = nil
        }
    }
    
    private func startEditing() {
        // Start editing and load existing or default data
        isEditing = true
        loadAccountData()
    }
    
    private func stopEditing() {
        // Stop editing and reset editing state
        isEditing = false
    }
    
    private func saveChanges() async {
        guard !userName.isEmpty else {
            print("SettingsAccountView: Username cannot be empty.")
            return
        }
        
        // Check if the username is available
        do {
            let isAvailable = try await viewModel.firebaseService.isUserNameAvailable(userName)
            if !isAvailable {
                print("SettingsAccountView: Username \(userName) is already taken.")
                return
            }
        } catch {
            print("SettingsAccountView: Failed to validate username availability: \(error.localizedDescription)")
            return
        }
        
        // Update or create the account
        do {
            if viewModel.user?.firestoreAccount != nil {
                // Update the account if it exists
                try await viewModel.updateAccount(
                    userName: userName,
                    profileImage: selectedImage,
                    playerLevel: playerLevel,
                    playerStatus: playerStatus
                    )
                print("SettingsAccountView: Account updated successfully.")
            } else {
                // Create a new account if none exists
                await createNewAccount()
            }
        } catch {
            print("SettingsAccountView: Failed to save changes: \(error.localizedDescription)")
        }
    }
    
    private func createNewAccount() async {
        guard let uid = viewModel.user?.uid else {
            print("SettingsAccountView: Unable to fetch user UID.")
            return
        }
        
        // Create a new account with provided or default values
        let newAccount = Account(
            id: UUID(),
            ownerUid: uid,
            userName: userName.isEmpty ? "new_user" : userName,
            profilePictureURL: nil,
            playerLevel: playerLevel.isEmpty ? "Beginner" : playerLevel,
            playerStatus: playerStatus.isEmpty ? "Just for fun" : playerStatus,
            friends: [],
            friendRequests: FriendRequests(incoming: [], outgoing: [])
        )
        
        do {
            // Save the new account to Firestore
            try await viewModel.firebaseService.saveAccount(newAccount, forUser: newAccount.ownerUid)
            
            // Update the ViewModel and user state
            viewModel.user?.firestoreAccount = newAccount
            print("SettingsAccountView: New account created successfully.")
        } catch {
            print("SettingsAccountView: Failed to create new account: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsAccountView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
