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
    @State private var profilePictureURL: String? = nil
    @State private var playerLevel = ""
    @State private var playerStatus = ""
    var profilePictureURLBinding: Binding<String> {
        Binding<String>(
            get: { profilePictureURL ?? "" },
            set: { profilePictureURL = $0.isEmpty ? nil : $0 }
        )
    }

    
    // Account Levels and Statuses
    let playerLevels = ["Beginner", "Intermediate", "Amateur", "Expert"]
    let playerStatuses = ["Just for fun", "Trainer", "Competitor/Professional"]
    
    var body: some View {
        NavigationStack {
            Form {
                if let account = viewModel.user?.account {
                    // Account Data Section
                    Section(header: Text("Account Information")) {
                        if !isEditing {
                            // Display account data
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
                                        image.resizable().scaledToFill().frame(width: 50, height: 50).clipShape(Circle())
                                    } placeholder: {
                                        Circle().fill(Color.gray).frame(width: 50, height: 50)
                                    }
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
                        } else {
                            // Edit account data
                            TextField("Username", text: $userName)
                            TextField("Profile Picture URL", text: profilePictureURLBinding)
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
                } else {
                    // No account section
                    Section {
                        Text("No account found. Create one to unlock more features.")
                            .foregroundColor(.secondary)
                        NavigationLink("Create Account") {
                            PersonalizationInputView().environmentObject(viewModel)
                               
                        }
                    }
                }
                
                // Actions Section
                Section {
                    if !isEditing {
                        Button("Edit Account") {
                            startEditing()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if viewModel.user?.account != nil {
                            Button("Delete Account") {
                                Task {
                                    await viewModel.removeAccount()
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
            .task {
                // Load initial data for editing
                loadAccountData()
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadAccountData() {
        if let account = viewModel.user?.account {
            userName = account.userName
            profilePictureURL = account.profilePictureURL
            playerLevel = account.playerLevel
            playerStatus = account.playerStatus
        } else {
            // Default values for new account creation
            userName = ""
            profilePictureURL = nil
            playerLevel = playerLevels.first ?? ""
            playerStatus = playerStatuses.first ?? ""
        }
    }
    
    private func startEditing() {
        isEditing = true
        loadAccountData()
    }
    
    private func stopEditing() {
        isEditing = false
    }
    
    private func saveChanges() async {
        guard !userName.isEmpty else {
            print("SettingsAccountView: Username cannot be empty.")
            return
        }
        
        await viewModel.updateAccountData(
            userName: userName,
            profilePictureURL: profilePictureURL,
            playerLevel: playerLevel,
            playerStatus: playerStatus
        )
    }
}


#Preview {
    SettingsAccountView().environmentObject(UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService()))
}
