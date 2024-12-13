//
//  ProfilePictureComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct ProfilePictureComponentView: View {
    @Binding var selectedImage: UIImage?
    let profilePictureURL: String?
    @Binding var showImagePicker: Bool
    
    var body: some View {
        HStack {
            Text("Profile Picture")
            Spacer()
            ZStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else if let profilePictureURL = profilePictureURL {
                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 50, height: 50)
                        .overlay(Text("Add").font(.caption).foregroundColor(.white))
                }
            }
            .onTapGesture {
                showImagePicker = true
            }
        }
    }
}
#Preview {
    //ProfilePictureComponentView(selectedImage: <#Binding<UIImage?>#>, profilePictureURL: <#String?#>, showImagePicker: <#Binding<Bool>#>)
}
