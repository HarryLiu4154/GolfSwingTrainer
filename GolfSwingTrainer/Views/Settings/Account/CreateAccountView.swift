//
//  PersonalizationInputView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-30.
//

import SwiftUI
import Foundation

struct CreateAccountView: View {
    @State private var username: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var playerLevel: String = ""
    @State private var playerStatus: String = ""
    @State private var isSaving = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: UserDataViewModel
    
    let levels = ["Beginner", "Intermediate", "Amateur", "Expert"]
    let statuses = ["Just for fun", "Trainer", "Competitor/Professional"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Why create an account?").font(.headline)) {
                    Text("Creating an account alias allows you to share your achievements and progress with your friends, colleagues, and trainer! It helps you stay competitive, showcase your personal records, and give your trainer more insights into your game. Creating an account also helps us tailor the app to your needs as a player.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Your Information").font(.headline)) {
                    // Username
                    TextField("Username (required)", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 5)
                    
                    // Profile Image Picker
                    HStack {
                        Text("Profile Image")
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
                    
                    // Player Level
                    Picker("Player Level", selection: $playerLevel) {
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    
                    // Player Status
                    Picker("Player Status", selection: $playerStatus) {
                        ForEach(statuses, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                }
                
                Section {
                    Button(action: saveUserInfo) {
                        HStack {
                            Spacer()
                            if isSaving {
                                //SettingsView()
                            } else {
                                Text("Continue")
                                Image(systemName: "arrow.right")
                            }
                            Spacer()
                        }
                    }
                    .disabled(isSaving || username.isEmpty)
                    .foregroundColor(username.isEmpty ? .gray : .blue)
                }
            }
            .navigationTitle("Create an Account")
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveUserInfo() {
        guard !username.isEmpty else {
            print("CreateAccountView: Username cannot be empty.")
            return
        }
        isSaving = true
        guard let image = selectedImage else {
            print("No image selected for upload.")
            isSaving = false
            return
        }

        print("Selected image dimensions: \(image.size.width)x\(image.size.height)")
        print("Preparing to upload image.")

        Task {
            await viewModel.updateAccountData(
                userName: username,
                profileImage: image, // Pass the selected image directly
                playerLevel: playerLevel,
                playerStatus: playerStatus
            )
            print("CreateAccountView: User info saved successfully.")
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - ImagePicker Helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                print("Image selected with dimensions: \(image.size.width)x\(image.size.height)")
                parent.selectedImage = image
            } else {
                print("No valid image selected.")
            }
            picker.dismiss(animated: true)
        }

        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    CreateAccountView()
}
