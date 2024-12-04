//
//  AccountFormComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct AccountFormComponentView: View {
    let account: Account
    let isEditing: Bool
    @Binding var selectedImage: UIImage?
    @Binding var playerLevel: String
    @Binding var playerStatus: String
    @Binding var showImagePicker: Bool
    
    let playerLevels: [String]
    let playerStatuses: [String]
    
    init(account: Account,
         isEditing: Bool,
         selectedImage: Binding<UIImage?>,
         playerLevel: Binding<String>,
         playerStatus: Binding<String>,
         showImagePicker: Binding<Bool>,
         playerLevels: [String] = ["Beginner", "Intermediate", "Amateur", "Expert"],
         playerStatuses: [String] = ["Just for fun", "Trainer", "Competitor/Professional"]) {
        self.account = account
        self.isEditing = isEditing
        self._selectedImage = selectedImage
        self._playerLevel = playerLevel
        self._playerStatus = playerStatus
        self._showImagePicker = showImagePicker
        self.playerLevels = playerLevels
        self.playerStatuses = playerStatuses
    }
    
    var body: some View {
        Form {
            Section(header: Text(isEditing ? "Edit Your Information" : "Account Information")) {
                // Username (non-editable)
                HStack {
                    Text("Username")
                    Spacer()
                    Text(account.userName)
                        .foregroundColor(.secondary)
                }
                
                // Profile Picture
                ProfilePictureComponentView(selectedImage: $selectedImage, profilePictureURL: account.profilePictureURL, showImagePicker: $showImagePicker)
                
                if isEditing {
                    // Editable Player Level
                    Picker("Player Level", selection: $playerLevel) {
                        ForEach(playerLevels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    // Editable Player Status
                    Picker("Player Status", selection: $playerStatus) {
                        ForEach(playerStatuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                } else {
                    // Display-only Player Level
                    HStack {
                        Text("Player Level")
                        Spacer()
                        Text(account.playerLevel).foregroundColor(.secondary)
                    }
                    
                    // Display-only Player Status
                    HStack {
                        Text("Player Status")
                        Spacer()
                        Text(account.playerStatus).foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    //AccountFormComponentView(account: <#Account#>, isEditing: <#Bool#>, selectedImage: <#Binding<UIImage?>#>, playerLevel: <#Binding<String>#>, playerStatus: <#Binding<String>#>, showImagePicker: <#Binding<Bool>#>)
}
