//
//  FriendsRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct FriendsRowComponentView: View {
    let friend: Friend
    var body: some View {
            HStack {
                Text(friend.userName)
                Spacer()
                if let profilePictureURL = friend.profilePictureURL {
                    AsyncImage(url: URL(string: profilePictureURL)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                    }
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 40, height: 40)
                        .overlay(Text(friend.userName.prefix(2).uppercased()))
                }
            }
        }
    }


#Preview {
    //FriendsRowComponentView(friend: User.MOCK_USER.firestoreAccount?.friends.first)
}
