//
//  MenuView.swift
//  GolfSwingTrainer
//
//  Created by David Romero on 2024-12-01.
//  tutorial --> https://www.youtube.com/watch?v=8Q0LFDkYIjU&t=1s

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var swingSessionViewModel: SwingSessionViewModel
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "person").foregroundStyle(.gray).imageScale(.large)
                NavigationLink(destination: UserProfileView()){
                    Text("Your Profile").foregroundStyle(.gray).font(.headline)
                }
            }.padding(.top, 100)
            HStack{
                Image(systemName: "gear").foregroundStyle(.gray).imageScale(.large)
                NavigationLink(destination: SettingsView().environmentObject(swingSessionViewModel)){
                    Text("Settings").foregroundStyle(.gray).font(.headline)
                }
            }.padding(.top, 100)
            Spacer()
        }.padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MenuView()
}
