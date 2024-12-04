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
                Spacer()
                Button("Accept") {
                    Task {
                        do {
                            await userDataViewModel.acceptFriendRequest(from: incoming)
                            await userDataViewModel.loadUser()
                        } catch {
                            feedbackMessage = "Error accepting request from \(incoming)"
                        }
                    }
                }
                .buttonStyle(.bordered)

                Button("Decline") {
                    Task {
                        do {
                            await userDataViewModel.declineFriendRequest(from: incoming)
                            await userDataViewModel.loadUser()
                        } catch {
                            feedbackMessage = "Error declining request from \(incoming)"
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
