//
//  MenuView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//  tutorial --> https://www.youtube.com/watch?v=8Q0LFDkYIjU&t=1s

import SwiftUI
import FirebaseAuth

///Hamburger menu that shows a welcome messages, settings, user profile and etc.
struct MenuView: View {
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        VStack(alignment: .leading){
            // Menu Header
            HStack {
                ZStack {
                    if let profilePictureURL = authViewModel.currentUser?.account?.profilePictureURL, !profilePictureURL.isEmpty {
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
                                Text(authViewModel.currentUser?.initials ?? "")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            )
                    }
                }
                Text("Welcome, \(authViewModel.currentUser?.fullName ?? "")")
                    .font(.headline)
            }
            .padding(.top, 30)

            Divider()
            HStack{
                Image(systemName: "person").foregroundStyle(.gray).imageScale(.large)
                NavigationLink(destination: UserProfileView().environmentObject(authViewModel)){
                    Text("Your Profile").foregroundStyle(.gray).font(.headline)
                }
            }.padding(.top, 30)
            HStack{
                Image(systemName: "gear").foregroundStyle(.gray).imageScale(.large)
                NavigationLink(destination: SettingsView().environmentObject(swingSessionViewModel).environmentObject(userDataViewModel)){
                    Text("Settings").foregroundStyle(.gray).font(.headline)
                }
            }
            .padding(.top, 30)
            Spacer()
        }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MenuView()
}
