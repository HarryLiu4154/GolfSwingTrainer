//
//  LoginView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//  Login UI refrence -> https://www.youtube.com/watch?v=QJHmhLGv-_0&t=14s&ab_channel=AppStuff

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: LoginViewModel
    @State private var email:String = ""
    @State private var password: String = ""
    
    init(appState: AppState) {
            // Initialize the ViewModel with the shared appState environment object
            _viewModel = StateObject(wrappedValue: LoginViewModel(appState: appState))
        }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                //Logo
                Image("capstone-logo-text").resizable().scaledToFill().frame(height: 200).padding(.vertical, 32)
                Spacer()
                
                //Email
                AuthInputView(text: $email, title: "Email Address", placeHolder: "Admin@Admin.com")
                /*TextField(String(localized: "Email"), text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)*/
                
                //Password
                AuthInputView(text: $password, title: "Password", placeHolder: "Enter your password")
                /*SecureField(String(localized: "Password"), text: $viewModel.password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)*/
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    viewModel.signIn()
                }) {
                    Text(String(localized: "Sign In"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                Button(action: {
                    viewModel.register()
                }) {
                    Text(String(localized: "Register"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }.padding()
            
            
            
        } //NavigationStack
    } //Body
} //struct


#Preview {
    LoginView(appState: AppState())
}
