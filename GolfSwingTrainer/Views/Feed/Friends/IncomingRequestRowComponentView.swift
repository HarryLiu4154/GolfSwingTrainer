//
//  IncomingRequestRowComponentView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-04.
//

import SwiftUI

struct IncomingRequestRowComponentView: View {
    let incoming: String
    @Binding var feedbackMessage: String?
    @EnvironmentObject var userDataViewModel: UserDataViewModel

    var body: some View {
        HStack {
            Text(incoming)
                .font(.headline)
            Spacer()
            Button("Accept") {
                Task {
                    do {
                        await userDataViewModel.acceptFriendRequest(from: incoming)
                        feedbackMessage = "You are now friends with \(incoming)."
                    } catch {
                        feedbackMessage = "Error accepting request from \(incoming): \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.green)

            Button("Decline") {
                Task {
                    do {
                        await userDataViewModel.declineFriendRequest(from: incoming)
                        feedbackMessage = "You declined the friend request from \(incoming)."
                    } catch {
                        feedbackMessage = "Error declining request from \(incoming): \(error.localizedDescription)"
                    }
                }
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
        }
    }
}


#Preview {
    //IncomingRequestRowComponentView()
}
