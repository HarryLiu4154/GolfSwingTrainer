//
//  LoginViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//

import Combine /* https://developer.apple.com/documentation/combine */
import SwiftUI
import FirebaseAuth
import FirebaseCore

/*firebase tutorial -> https://www.youtube.com/watch?v=q-9lx7aSWcc&ab_channel=Firebase */

/*View Model used to decouple login auth logic*/
class LoginViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    private var appState: AppState
    init(appState: AppState) {
            self.appState = appState
        }
    
    //Register new user
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = "Account created successfully!"
                self.appState.isLoggedIn = true // Automatically log in upon successful registration
            }
        }
    }
    
    //Sign in registered user
    func signIn(){
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                //self.isLoggedIn = true
                self.appState.isLoggedIn = true // Update app state on successful login
                self.errorMessage = ""
            }
        }
    }
}

