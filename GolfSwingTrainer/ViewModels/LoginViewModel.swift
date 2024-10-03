//
//  LoginViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//

import Combine /* https://developer.apple.com/documentation/combine */
import SwiftUI

/*View Model used to decouple login auth logic*/
class LoginViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    //Register new user
    func register(){
        
    }
    
    //Sign in registered user
    func signIn(){
        
    }
}
