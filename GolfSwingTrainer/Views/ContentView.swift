//
//  ContentView.swift
//  GolfSwingTrainer
//
//  Created by Harry Liu on 2024-09-10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group{
            if viewModel.userSession != nil {
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
