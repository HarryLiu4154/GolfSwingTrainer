//
//  LoginView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-01.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20){
            
            //Email
            TextField("Email", text: $viewModel.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
            
            //Password
            SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        
                        if !viewModel.errorMessage.isEmpty {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
                        }
            
            Button(action: {
                            viewModel.signIn()
                        }) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
            Button(action: {
                viewModel.register()
            }) {
                Text("Register")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }.padding()
    }
}

#Preview {
    LoginView()
}
