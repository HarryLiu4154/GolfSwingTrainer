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
    @EnvironmentObject var viewModel: AuthViewModel
    
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
                        Task{
                            try await viewModel.signIn(withEmail: email, password: password)
                        }
                    }label: {
                        HStack{
                            Text("Sign in").fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }.foregroundStyle(.white).frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                        .clipShape(.buttonBorder)
                        .padding(.top, 24)
                    
                    Spacer()
                    
                    //register button
                    NavigationLink{
                        RegistrationView().navigationBarBackButtonHidden(true).environmentObject(viewModel)
                    }label: {
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
extension LoginView: AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

#Preview {
    LoginView().environmentObject(AuthViewModel(userDataViewModel: UserDataViewModel(coreDataService: CoreDataService(), firebaseService: FirebaseService())))
}
