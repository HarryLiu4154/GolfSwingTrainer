//
//  RegistrationView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPasswword = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            Image("capstone-logo").resizable().scaledToFill().frame(height: 200).padding(.vertical, 32)
            VStack(spacing: 24){
                //Email
                AuthInputComponentView(text: $email, title: "Email Address", placeHolder: "admin@admin.com")
                
                //Full Name
                AuthInputComponentView(text: $fullName, title: "Full Name", placeHolder: "Enter your full Name")
                
                //Password
                AuthInputComponentView(text: $password, title: "Password", placeHolder: "Enter your password",isSecureField: true)
                
                //Re-enter password
                AuthInputComponentView(text: $confirmPasswword, title: "Confirm Password", placeHolder: "Re-enter your password", isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            //Register Button
            Button{
                print("Registering user...")
            }label: {
                HStack{
                    Text(String(localized: "Register")).fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }.foregroundStyle(.white).frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }.background(Color(.systemBlue)).clipShape(.buttonBorder).padding(.top, 24)
            
            Spacer()
            
            //Sign in button
            Button{
                dismiss()
            }label: {
                HStack(spacing: 2){
                    Text(String(localized: "Already have an account?"))
                    Text(String(localized: "Sign in")).fontWeight(.bold)
                }.font(.system(size: 16))
            }
        }
        
    }
}

#Preview {
    RegistrationView()
}
