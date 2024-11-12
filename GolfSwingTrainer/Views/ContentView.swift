//
//  ContentView.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI

//TODO: Rename this file or maybe inject it somewhere else
struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        Group{
            if viewModel.userSession != nil {
                //UserProfileView()
                UserProfileView()
            }else{
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView().environmentObject(AuthViewModel())
}
