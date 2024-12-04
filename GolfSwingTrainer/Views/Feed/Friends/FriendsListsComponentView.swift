//
//  FriendsListsComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct FriendsListsComponentView: View {
    let account: Account
    @Binding var feedbackMessage: String?
    @EnvironmentObject var userDataViewModel: UserDataViewModel
    var body: some View {
        List {
            // Friends Section
            if !account.friends.isEmpty {
                Section(header: Text("Friends")) {
                    ForEach(account.friends, id: \.id) { friend in
                        FriendsRowComponentView(friend: friend)
                    }
                }
            }
            
            // Incoming Friend Requests Section
            if !account.friendRequests.incoming.isEmpty {
                Section(header: Text("Incoming Friend Requests")) {
                    ForEach(account.friendRequests.incoming, id: \.self) { incoming in
                        IncomingRequestRowComponentView(
                            incoming: incoming,
                            feedbackMessage: $feedbackMessage
                        )
                    }
                }
            }
            
            // Outgoing Friend Requests Section
            if !account.friendRequests.outgoing.isEmpty {
                Section(header: Text("Outgoing Friend Requests")) {
                    ForEach(account.friendRequests.outgoing, id: \.self) { outgoing in
                        OutgoingRequestRowComponentView(outgoing: outgoing)
                    }
                }
            }
        }
    }
}

#Preview {
    FriendsListsComponentView(account: User.MOCK_USER.firestoreAccount!, feedbackMessage: .constant("message"))
}
