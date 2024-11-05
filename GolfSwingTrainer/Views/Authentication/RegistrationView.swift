//
//  RegistrationView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullName = ""
    @State private var password = ""
    @State private var confirmPasswword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
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
                ZStack(alignment: .trailing){
                    AuthInputComponentView(text: $confirmPasswword, title: "Confirm Password", placeHolder: "Re-enter your password", isSecureField: true)
                    
                    if !password.isEmpty && !confirmPasswword.isEmpty{
                        if password == confirmPasswword{
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemGreen))
                        }else{
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(.systemRed))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            //Register Button
            Button{
                Task{
                    try await viewModel.createUser(withEmail: email, password: password, fullName: fullName)
                }
            }label: {
                HStack{
                    Text(String(localized: "Register")).fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }.foregroundStyle(.white).frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
                .clipShape(.buttonBorder)
                .padding(.top, 24)
            
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
extension RegistrationView: AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPasswword == password
        && !fullName.isEmpty
    }
}

#Preview {
    RegistrationView().environmentObject(AuthViewModel())
}
