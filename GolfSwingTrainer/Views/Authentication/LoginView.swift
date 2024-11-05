//
//  LoginView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//  Login UI refrence -> https://www.youtube.com/watch?v=QJHmhLGv-_0&t=14s&ab_channel=AppStuff

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack{
            VStack{
                VStack{
                    //Image
                    Image("capstone-logo-text").resizable().scaledToFill().frame(height: 200).padding(.vertical, 32)
                    VStack(spacing: 24){
                        //email
                        AuthInputComponentView(text: $email, title: String(localized: "Email Address"),placeHolder: "admin@admin.com").textInputAutocapitalization(.none)
                        
                        //password
                        AuthInputComponentView(text: $password, title: String(localized: "Password"),placeHolder: String(localized: "Enter your password"), isSecureField: true)
                        
                    }.padding(.horizontal).padding(.top, 12)
                    
                    //Sign In Button
                    Button{
                        print("Logging user in...")
                    }label: {
                        HStack{
                            Text("Sign in").fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }.foregroundStyle(.white).frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }.background(Color(.systemBlue)).clipShape(.buttonBorder).padding(.top, 24)
                    
                    Spacer()
                    
                    //register button
                    NavigationLink{
                        //
                        RegistrationView().navigationBarBackButtonHidden(true)
                    }label: {
                        //
                        HStack(spacing: 2){
                            Text(String(localized: "Don't have an account?"))
                            Text(String(localized: "Sign up")).fontWeight(.bold)
                        }.font(.system(size: 16))
                    }
                }
            }
        }
    }
}

#Preview {
    //LoginView(appState: AppState())
    LoginView()
}
