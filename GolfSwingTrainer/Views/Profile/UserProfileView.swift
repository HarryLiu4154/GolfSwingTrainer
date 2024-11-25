//
//  UserProfileView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-11-04.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showDeleteConfirmation = false //Controls the delete account pop up confirmation
    var body: some View {
        NavigationStack{
            if let user = viewModel.currentUser {
                List{
                    Section{
                        HStack{
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4){
                                Text(user.fullName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                                
                            }
                            
                        }
                    }
                    Section("General"){
                        HStack{
                            SettingRowComponentView(imageName: "gear", title: String(localized: "Version"), tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text("v1.0.0" + " - " + String(localized: "Alpha")).foregroundStyle(.gray)
                        }
                    }
                    Section("Account"){
                        Button{
                            viewModel.signOut()
                        }label: {
                            SettingRowComponentView(imageName: "arrow.left.circle.fill", title: "Sign out", tintColor: Color.yellow)
                            
                        }
                        Button{
                            print("Button: Delete user account pressed")
                            showDeleteConfirmation = true
                        }label: {
                            SettingRowComponentView(imageName: "trash", title: "DELETE ACCOUNT", tintColor: Color.red)
                        }.alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("Are you sure?"),
                                message: Text("This action will permanently delete your account."),
                                primaryButton: .destructive(Text("Delete")) {
                                    Task {
                                        await viewModel.deleteAccount()
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }.navigationTitle("Your Profile")
            }
        }
    }
}

#Preview {
    
    UserProfileView().environmentObject(AuthViewModel(userDataViewModel: UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService())))
}
