//
//  UserAccountView.swift
//  GolfSwingTrainer Watch App
//
//  Created by David Romero on 2024-10-02.
//

import SwiftUI

struct UserAccountView: View {
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 15){
                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.blue)
                                        .padding(.top)
                                        .padding(.bottom, 10)
                                        .frame(maxWidth: .infinity, alignment: .center)
                    Group() {
                                        Text("Username")
                                            .font(.headline)
                                        Text("David")
                                            .font(.body)
                                        Text("Email")
                                            .font(.headline)
                                        Text("test@test.com")
                                            .font(.body)
                                        
                                        Text("Member Since")
                                            .font(.headline)
                                        Text("January 2021")
                                            .font(.body)
                                    }
                    
                }.navigationTitle("Account")
            }
        }
    }
}

#Preview {
    UserAccountView()
}
