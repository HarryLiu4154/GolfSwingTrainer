//
//  InAppNotificationView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-02.
//

import SwiftUI

///Reusable in app notification
struct InAppNotificationView: View {
    let title: String
    let message: String
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(title).bold()
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            }
            .animation(.easeInOut, value: isVisible)
            .transition(.move(edge: .top))
        }
    }
}

#Preview {
    InAppNotificationView(title: "", message: "", isVisible: .constant(true))
}
