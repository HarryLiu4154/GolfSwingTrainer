//
//  LoginViewModel.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-10-03.
//  firebase tutorial -> https://www.youtube.com/watch?v=q-9lx7aSWcc&ab_channel=Firebase

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol{
    var formIsValid: Bool {get}
}
@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User? //Help's determine if user is logged in or not
    @Published var currentUser: User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
            await fetchUser()
        }
    }
    func signIn(withEmail email: String, password: String) async throws {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
            print("AuthViewModel: signIn() -> Successfully signed in user: \(result.user.email ?? "")")
        }catch{
            print("AuthViewModel: signIn() -> FAILED Signing in with error: \(error.localizedDescription)...")
        }
        print("AuthViewModel: Signing in \(String(describing: currentUser?.fullname)), with Email: \(String(email))...")
    }
    func createUser(withEmail email: String, password: String, fullName: String) async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            print("AuthViewModel: createUser() -> Created a user with email: \(String(describing: email)), ") //Debug message
            await fetchUser()
        }catch{
            
            print("AuthViewModel: createUser() -> Failed to create a user with error: \(error.localizedDescription)") //Debug message
        }
        
        
        print("AuthViewModel: Creating User \(String(describing: currentUser?.fullname)), with Email: \(String(email))...")
    }
    func signOut(){
        do{
            try Auth.auth().signOut() //signs out the backend
            self.userSession = nil //wipes user session and returns to login screen
            self.currentUser = nil //wipes data model
        }catch{
            print("AuthViewModel: FAILED to sign out User with error \(error.localizedDescription)...") //Debug message
        }
        
        print("AuthViewModel: Signing out User...") //Debug message
    }
    func deleteAccount(){
        
        
        print("AuthViewModel: deleting account...") //Debug message
    }
    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
      
        print("AuthViewModel: fetching user \(String(describing: self.currentUser))...") //Debug message
    }

}

